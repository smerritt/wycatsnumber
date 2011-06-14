(ns org.andcheese.wycatsnumber.webapp
  (:use compojure.core
        ring.adapter.jetty)
  (:require [clj-yaml [core :as yaml]]
            [clojure.contrib [sql :as sql]]
            [org.danlarkin [json :as json]]
            [org.andcheese.wycatsnumber
             [graph :as graph]
             [db :as db]]
            [ring.middleware [params :as params-middleware]]))

(defmacro with-db [& body]
  `(sql/with-connection db/connection
     ~@body))

(defn load-graph-into [ref]
  "Load collaborations into a graph. The idea is to update our one big cached graph
   in-place, instead of building a whole second copy and swapping it out. Keeps memory
   usage lower."
  (with-db
    (sql/with-query-results collaborations
      ["SELECT authors.github_username AS author,
               authors.gravatar_id     AS gravatar_id,
               collaborations.commits  AS commits,
               projects.name           AS project
        FROM authors
          JOIN collaborations ON authors.id = collaborations.author_id
          JOIN projects ON projects.id = collaborations.project_id
        ORDER BY author DESC"]
      (loop [collab-sets (partition-all 1000 collaborations)]
        (if (empty? collab-sets)
          nil
          (let [collab-set (first collab-sets)]
            (dosync
             (loop [cs collab-set]
               (if (empty? cs)
                 nil
                 (let [{:keys [author project commits gravatar_id]} (first cs)]
                   (alter ref
                          #(-> %1
                               (graph/add-edge author project commits)
                               (graph/tag-node author gravatar_id)))
                   (recur (rest cs))))))
            (recur (rest collab-sets))))))))

;; This will probably get baked in in some future Clojure version, I'd imagine.
(defn queue? [x]
  (= clojure.lang.PersistentQueue (class x)))

(defn wheel-map [fns coll]
  "Returns a lazy seq that is the result of applying the first fn in fns to the first element of coll, the second fn to the second element, ..., the nth fn to the nth element, the first fn to the (n+1)th element, and so on.

Think of making a wheel out of the fns and rolling it up coll."
  (if (not (queue? fns))
    (wheel-map (into clojure.lang.PersistentQueue/EMPTY fns) coll)
    (lazy-seq
     (if (empty? coll)
       (list)
       (cons ((first fns) (first coll))
             (wheel-map (conj (pop fns)
                              (first fns))
                        (rest coll)))))))

(defn to-api-author [path-component]
  {:type "author"
   :name (path-component :node)
   :gravatar_id (path-component :tag)})

(defn to-api-project [path-component]
  {:type "project"
   :name (path-component :node)})

(defn api-responsify [path]
  (wheel-map [to-api-author to-api-project] path))

(def the-graph (ref (graph/vacant)))

(defn json-response
  ([body] {:headers {"Content-Type" "application/json"}
           :body (json/encode body)})
  ([status body]
     (assoc (json-response body)
       :status 404)))

(defn require-known-authors [authors func]
  (let [unknown-authors (filter #(not (graph/has-node? @the-graph %))
                                authors)]
    (if (seq unknown-authors)
         (json-response 404 {:unknown-authors unknown-authors})
         (func))))

(defn handle-path-request
  ([author1 author2]
     (handle-path-request author1 author2 1))
  ([author1 author2 min-weight]
     (require-known-authors
      [author1 author2]
      #(-> (graph/path @the-graph author1 author2 min-weight)
          api-responsify
          json-response))))

(defn handle-friend-request
  ([author distance]
     (handle-friend-request author distance 0))
  ([author distance min-weight]
     (require-known-authors
      [author]
      (fn []
        (->> (graph/bfs-from @the-graph
                             author
                             min-weight)
             (take-while #(<= (% :depth)
                              (* 2 distance)))
             (filter #(= (* 2 distance)
                         (% :depth)))
             (map (fn [x]
                    {:name        (x :node)
                     :gravatar_id (x :tag)}))
             (json-response))))))

(defn handle-all-paths-request
  ([src dest]
     (handle-all-paths-request src dest 0))
  ([src dest min-weight]
     (require-known-authors
      [src dest]
      #(->> (graph/all-paths @the-graph src dest min-weight)
           (map api-responsify)
           json-response))))

(defn handle-status-request []
  (json-response (graph/info @the-graph)))

(defn print-request [handler]
  (fn [request]
    (println request)
    (handler request)))

(defn print-response [handler]
  (fn [request]
    (let [response (handler request)]
      (println response)
      response)))

(defn jsonp-ify [handler]
  "If the response is JSON and the request contains the 'callback' parameter
  wraps the response body, e.g. \"$callback($response)\")"
  (fn [request]
    (if-let [jsonp (get-in request
                           [:query-params "callback"])]
      (let [response (handler request)]
        (if (= "application/json"
               (get-in response [:headers "Content-Type"]))
          (-> response
              (assoc :body (str jsonp "(" (response :body) ");"))
              (update-in [:headers "Content-Type"] (constantly "application/javascript")))
          response))
      (handler request))))

(defn remove-context [handler]
  "Strips the servlet-context part out of the request map
   so that your routes still work when deployed in a
   servlet container.

  Does nothing to help you generate self-referential links."
  (fn [request]
    (if-let [context (:context request)]
      (let [uri (:uri request)]
        (if (.startsWith uri context)
          (let [minus-context (.substring uri
                                          (.length context))
                uri-minus-context (if (= "" minus-context)
                                    "/"
                                    minus-context)]
            (handler (assoc request
                       :uri uri-minus-context)))
          (handler request)))
      (handler request))))

(def api-routes
     (-> (routes
          (GET "/" []
               "Hello World")
          (GET "/status" [] (handle-status-request))
          (GET "/path/:author1/:author2" [author1 author2]
               (handle-path-request author1 author2))
          (GET "/path/:author1/:author2/:weight" [author1 author2 weight]
               (handle-path-request author1 author2 (Integer/parseInt weight)))
          (GET "/friends/:author" [author]
               (handle-friend-request author 1))
          (GET "/friends/:author/:weight" [author weight]
               (handle-friend-request author 1 (Integer/parseInt weight)))
          (GET "/foaf/:author" [author]
               (handle-friend-request author 2))
          (GET "/foaf/:author/:weight" [author weight]
               (handle-friend-request author 2 (Integer/parseInt weight)))
          (GET "/all-paths/:author1/:author2" [author1 author2]
               (handle-all-paths-request author1 author2))
          (GET "/all-paths/:author1/:author2/:weight" [author1 author2 weight]
               (handle-all-paths-request author1 author2 (Integer/parseInt weight)))
          (ANY "*" [request] (fn [request] (json-response 404 request))))
         jsonp-ify
         remove-context
         params-middleware/wrap-params))

(defn init-graph []
  (load-graph-into the-graph))

(defn periodically-refresh-graph [interval]
  "Refresh the graph every interval milliseconds."
  (Thread/sleep interval)
  (init-graph)
  (recur interval))

(defn init-world []
  (init-graph)
  (.start (Thread. #(periodically-refresh-graph 3600000))))

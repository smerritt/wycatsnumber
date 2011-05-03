(ns org.andcheese.wycatsnumber.webapp
  (:use compojure.core
        ring.adapter.jetty)
  (:require [clj-yaml [core :as yaml]]
            [clojure.contrib [sql :as sql]]
            [org.danlarkin [json :as json]]
            [org.andcheese.wycatsnumber [graph :as graph]]))

(defn db-connection [database-yml]
    (let [env (or (System/getenv "RING_ENV")
                  "development")
          ;; This config/database.yml is for a Rails web app, and so has
          ;; keys like ":test", ":development", which get translated into
          ;; Clojure keywords.
          config ((yaml/parse-string database-yml)
                  (keyword env))
          db-host (config (keyword "host"))
          db-user (config (keyword "user"))
          db-pass (config (keyword "password"))
          db-name (config (keyword "database"))]
      {
       ;; just hardcode this one; I don't have the patience to
       ;; translate Ruby class names to Java ones. It's not a
       ;; simple transformation, either.
       :classname "org.postgresql.Driver"

       :subprotocol "postgresql"
       :subname (str "//" db-host ":5432/" db-name)
       :user db-user
       :password db-pass
       }))

;; project IDs and author IDs can collide, but they're all natural
;; numbers, so we can use the whole number line to make room
(def node-from-project-id -)
(def project-id-from-node -)
(def node-from-author-id identity)
(def author-id-from-node identity)

(defmacro with-db [& body]
  `(sql/with-connection (db-connection (slurp "config/database.yml"))
     ~@body))

(defn load-graph []
  (with-db
    (sql/with-query-results collaborations
      ["select * from collaborations order by id desc"]
      (reduce (fn [g collaboration]
                (graph/add-edge g
                                (node-from-author-id (collaboration :author_id))
                                (node-from-project-id (collaboration :project_id))
                                (collaboration :commits)))
              (graph/vacant)
              collaborations))))

(defn author-name-to-id [author-name]
  (sql/with-query-results result
    ["select id from authors where github_username = ?" author-name]
    (if (seq result)
      ((first result) :id)
      nil)))

(defn author-id-to-name [author-id]
  (sql/with-query-results result
    ["select github_username from authors where id = ?" author-id]
    ((first result) :github_username)))

(defn sql-placeholders [n]
  "Returns N comma-separated questionmarks between parens, e.g. (?,?,?)"
  (str
   "("
   (apply str
          (interpose ","
                     (repeatedly n (fn [] "?"))))
   ")"))

(defn author-attributes [author-ids]
  (if (seq author-ids)
    (let [placeholders (sql-placeholders (count author-ids))]
      (sql/with-query-results result
        (into [(str "select id, github_username as name, gravatar_id from authors where id in" placeholders)]
               author-ids)
        (reduce (fn [all-attrs these-attrs]
                  (assoc all-attrs
                    (these-attrs :id)
                    {:name (these-attrs :name)
                     :gravatar_id (these-attrs :gravatar_id)}))
                {}
                result)))
    {}))

(defn project-attributes [project-ids]
  (if (seq project-ids)
    (let [placeholders (sql-placeholders (count project-ids))]
      (sql/with-query-results result
        (into [(str "select id, name from projects where id in " placeholders)]
              project-ids)
        (reduce (fn [all-attrs these-attrs]
                  (assoc all-attrs
                    (these-attrs :id)
                    {:name (these-attrs :name)}))
                {}
                result)))
    {}))

(defn every-nth [n coll]
  (map first
       (partition 1 n coll)))

(defn left-rotate [v]
  "Rotates a vector to the left, e.g. [1 2 3] --> [2 3 1]"
  (conj (subvec v 1)
        (v 0)))

(defn wheel-map [fns coll]
  "Returns a lazy seq that is the result of applying the first fn in fns to the first element of coll, the second fn to the second element, ..., the nth fn to the nth element, the first fn to the (n+1)th element, and so on.

Think of making a wheel out of the fns and rolling it up coll."
  (if (not (vector? fns))
    (wheel-map (vector fns) coll)
    (if (seq coll)
      (lazy-cat (list ((first fns) (first coll)))
                (wheel-map (left-rotate fns)
                           (rest coll)))
      '())))

(defn nodes-to-db-ids [nodes]
  (wheel-map [author-id-from-node project-id-from-node] nodes))

(defn api-responsify [ids]
  ;; ids is a seq of (author-id, project-id, author-id, project-id,
  ;; ...)
  (let [author-ids (every-nth 2 ids)
        project-ids (every-nth 2 (drop 1 ids))
        author-info (author-attributes author-ids)
        project-info (project-attributes project-ids)]
    (wheel-map [author-info project-info] ids)))

(def the-graph (ref (load-graph)))

(defn path-between-authors
  ([author-id1 author-id2]
     (path-between-authors author-id1 author-id2 1))
  ([author-id1 author-id2 min-weight]
     (nodes-to-db-ids
      (graph/path @the-graph author-id1 author-id2 min-weight))))

(defn handle-path-request [author-name1 author-name2]
  (with-db
         (let [author-id1 (author-name-to-id author-name1)
               author-id2 (author-name-to-id author-name2)]
           (if (or (nil? author-id1)
                   (nil? author-id2))
             (let [unknown-authors (map first
                                        (filter #(nil? (second %1))
                                                [[author-name1 author-id1]
                                                 [author-name2 author-id2]]))]
               {:status 404
                :body (json/encode {:unknown-authors unknown-authors})})
             (json/encode
              (api-responsify
               (path-between-authors author-id1
                                     author-id2)))))))

(defroutes api-routes
  (GET "/" []
       "Hello World")
  (GET "/path/:author1/:author2" [author1 author2]
       (handle-path-request author1 author2)))

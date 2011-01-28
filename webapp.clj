(ns wycatsnumber
  (:use compojure.core
        ring.adapter.jetty)
  (:require [clj-yaml [core :as yaml]]
            [clojure.contrib [sql :as sql]]))

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

(defn empty-graph []
  {:nodes (sorted-set)
   :edges {}})

(defn add-to-graph [graph node1 node2 weight]
  {:nodes (conj (graph :nodes)
                node1
                node2)
   :edges (assoc (graph :edges)
            ;; NB: graph is undirected
            node1
            (conj (get (graph :edges)
                       node1
                       {})
                  [node2 weight])
            node2
            (conj (get (graph :edges)
                       node2
                       {})
                  [node1 weight]))})

(defn neighbors [graph node]
  ((graph :edges)
   node
   {}))


;; project IDs and author IDs can collide, but they're all natural
;; numbers, so we can use the whole number line to make room
(defn node-from-project-id [project-id]
  (- project-id))
(defn project-id-from-node [node]
  (- node))
(def node-from-author-id identity)
(def author-id-from-node identity)

(defn path
  ([graph src dest]
     (path graph src dest 1))
  ([graph src dest min-weight]
     (loop [queue [src]
            predecessor {}
            seen (hash-set)
            examined 0]
       (if (empty? queue)
         nil
         (let [current-node (first queue)]
           (if (seen current-node)
             (recur (subvec queue 1)
                    predecessor
                    seen
                    examined)
             (let [new-neighbors (map first
                                      (filter (fn [[neighbor, edge-weight]]
                                                (and (not (= neighbor src))
                                                     (>= edge-weight min-weight)
                                                     (not (predecessor neighbor))))
                                              (neighbors graph current-node)))]
               (if (= current-node dest)
                 (loop [path [current-node]
                        next-node (predecessor current-node)]
                   (println "Examined " examined " nodes")
                   (if (not next-node)
                     path
                     (recur (conj path next-node)
                            (predecessor next-node))))
                 (recur (reduce (fn [acc n]
                                  (conj acc n))
                                (subvec queue 1)
                                new-neighbors)
                        (reduce (fn [acc n]
                                  (assoc acc n current-node))
                                predecessor
                                new-neighbors)
                        (conj seen current-node)
                        (+ 1 examined))))))))))

(defn load-graph []
  (sql/with-connection (db-connection (slurp "config/database.yml"))
    (sql/with-query-results collaborations
      ["select * from collaborations order by id desc"]
      (reduce (fn [g collaboration]
                (add-to-graph g
                              (node-from-author-id (collaboration :author_id))
                              (node-from-project-id (collaboration :project_id))
                              (collaboration :commits)))
              (empty-graph)
              collaborations))))

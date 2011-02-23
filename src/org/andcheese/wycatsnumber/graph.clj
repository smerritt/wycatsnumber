(ns org.andcheese.wycatsnumber.graph
  (:require [org.andcheese.wycatsnumber [queue :as queue]]))

(defn empty []
  {:nodes (sorted-set)
   :edges {}})

(defn add-edge [graph node1 node2 weight]
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

(defn path
  ([graph src dest]
     (path graph src dest 1))
  ([graph src dest min-weight]
     (loop [queue (queue/add (queue/vacant) [src])
            predecessor {}
            seen (hash-set)
            examined 0]
       (if (empty? queue)
         nil
         (let [[current-node rest-of-queue] (queue/dequeue queue)]
           (if (seen current-node)
             (recur rest-of-queue
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
                   (if (not next-node)
                     path
                     (recur (conj path next-node)
                            (predecessor next-node))))
                 (recur (queue/add rest-of-queue
                                   new-neighbors)
                        (reduce (fn [acc n]
                                  (assoc acc n current-node))
                                predecessor
                                new-neighbors)
                        (conj seen current-node)
                        (+ 1 examined))))))))))


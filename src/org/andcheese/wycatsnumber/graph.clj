(ns org.andcheese.wycatsnumber.graph
  (:require [org.andcheese.wycatsnumber [queue :as queue]]))

(defn vacant []
  "Graph with no nodes and no edges. Just a skeleton."
  {:nodes (hash-set)
   :edges {}})

(defn add-edge [graph node1 node2 weight]
  "Add an edge (node1 -> node2) and (node2 -> node1) with the given weight.

If node1 or node2 don't exist in the graph, they will be added."
  (conj-edge (conj-edge (conj-node (conj-node graph
                                              node1)
                                   node2)
                        node1
                        node2
                        weight)
             node2
             node1
             weight))

(defn conj-edge [graph node1 node2 weight]
  "Internal utility function.

Add an edge from node1 to node2 with the given weight."
  (update-in graph
             [:edges node1]
             assoc
             node2
             weight))

(defn conj-node [graph node]
  "Internal utility function.

Add node to graph."
  (update-in graph
             [:nodes]
             #(conj %1 %2)
             node))

(defn neighbors [graph node]
  "Returns neighbors of node + their edge-weights as a seq of [neighbor, weight] pairs."
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


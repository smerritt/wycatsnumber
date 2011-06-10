(ns org.andcheese.wycatsnumber.graph
  (:require [org.andcheese.wycatsnumber [queue :as queue]]))

(defn vacant []
  "Graph with no nodes and no edges. Just a skeleton."
  {:nodes (hash-set)
   :edges {}})

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

(defn add-edge [graph node1 node2 weight]
  "Add an edge (node1 -> node2) and (node2 -> node1) with the given weight.

If node1 or node2 don't exist in the graph, they will be added."
  (-> graph
      (conj-node node1)
      (conj-node node2)
      (conj-edge node1 node2 weight)
      (conj-edge node2 node1 weight)))

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


(defn bfs-from-1 [graph queue min-weight predecessor depth]
  (lazy-seq
   (if (empty? queue)
     (list)
     (let [this-node (first queue)
           this-depth (if-let [pred-depth (depth (predecessor this-node))]
                        (+ 1 pred-depth)
                        0)
           new-neighbors (map first
                              (filter (fn [[neighbor, edge-weight]]
                                        (and (>= edge-weight min-weight)
                                             (not (depth neighbor))
                                             (not (= neighbor this-node))))
                                      (neighbors graph this-node)))]
       (cons {:node this-node
              :predecessor (predecessor this-node)
              :depth this-depth}
             (bfs-from-1 graph
                         (if (empty? new-neighbors)
                           (pop queue)
                           (apply conj (pop queue) new-neighbors))
                         min-weight
                         (reduce (fn [acc neigh]
                                   (assoc acc neigh this-node))
                                 predecessor
                                 new-neighbors)
                         (assoc depth this-node this-depth)))))))

(defn bfs-from
  "Returns a lazy seq of nodes encountered on a breadth-first search of the graph
  starting from origin. Sequence elements are maps of the form
  {:node node, :predecessor predecessor (or nil for origin), :depth depth}.

  Optional min-weight argument (default 0) is the weight that an edge must
  have in order to count; this allows filtering of weak connections."
  ([graph origin] (bfs-from graph origin 0))
  ([graph origin min-weight]
     (bfs-from-1 graph
                 (conj clojure.lang.PersistentQueue/EMPTY origin)
                 min-weight
                 {}
                 {})))

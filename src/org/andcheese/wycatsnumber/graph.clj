(ns org.andcheese.wycatsnumber.graph)

(defn vacant []
  "Graph with no nodes and no edges. Just a skeleton."
  {:nodes (hash-set)
   :edges {}
   :node-tags {}})

(defn info [graph]
  "Some basic statistics about the graph."
  {
   :nodes (count (graph :nodes))
   :edges (reduce +
                  0
                  (map #(count (second %))
                       (graph :edges)))
   :tagged-nodes (count (graph :node-tags))})

(defn conj-edge [graph node1 node2 weight]
  "Internal utility function.

Add an edge from node1 to node2 with the given weight."
  (assoc-in graph [:edges node1 node2] weight))

(defn conj-node [graph node]
  "Internal utility function.

Add node to graph."
  (update-in graph
             [:nodes]
             #(conj %1 %2)
             node))

(defn tag-node [graph node tag]
  "Set tag as the data for node. It'll turn up in results from path and bfs-path."
  (assoc-in graph [:node-tags node] tag))

(defn tag-for [graph node]
  "Returns the tag data set by tag-node."
  (get-in graph [:node-tags node]))

(defn add-edge [graph node1 node2 weight]
  "Add an edge (node1 -> node2) and (node2 -> node1) with the given weight.

If node1 or node2 don't exist in the graph, they will be added."
  (-> graph
      (conj-node node1)
      (conj-node node2)
      (conj-edge node1 node2 weight)
      (conj-edge node2 node1 weight)))

(defn has-node? [graph node]
  (boolean ((graph :nodes) node)))

(defn neighbors [graph node min-weight]
  "Returns neighbors of node + their edge-weights as a seq.
   Nodes weighing less than min-weight are ignored."
  (->> (get-in graph [:edges node] {})
       (filter (fn [[_, weight]] (<= min-weight weight)))
       (map first)))

(defn degree
  "Degree of a node."
  ([graph node]
     (degree graph node 0))
  ([graph node min-weight]
     (count (neighbors graph node min-weight))))

(defn make-path-node [graph node]
  "Internal utility function. Used to make returned-node values from path."
  (let [result {:node node}]
    (if-let [tag (tag-for graph node)]
      (assoc result :tag tag)
      result)))

(defn path-via [node nexthop]
  "Internal utility function.

   Given a node N and a map of {thisnode -> nextnode}, returns the path
   from N until its eventual destination.

   Cycles in nexthop will cause infinite runtime; don't do that."
  (loop [path (list node)]
    (let [this-node (peek path)]
      (if-let [next-node (nexthop this-node)]
        (recur (conj path next-node))
        path))))

(defn path
  "Returns path from src to dest. Returned nodes are of the form
   {:node node, :tag tag-for-node}. :tag will be nil if no tag was set."
  ([graph src dest]
     (path graph src dest 0))
  ([graph src dest min-weight]
     (loop [queue (conj (clojure.lang.PersistentQueue/EMPTY) src)
            predecessor {}
            seen (hash-set)]
       (if (empty? queue)
         nil
         (let [current-node (first queue)]
           (if (seen current-node)
             (recur (pop queue)
                    predecessor
                    seen)
             (let [new-neighbors (->> (neighbors graph current-node min-weight)
                                      (filter (fn [neighbor]
                                           (and (not (= neighbor src))
                                                (not (predecessor neighbor))))))]
               (if (= current-node dest)
                 (map #(make-path-node graph %)
                      (path-via current-node predecessor))
                 (recur (into (pop queue) new-neighbors)
                        (reduce #(assoc %1 %2 current-node)
                                predecessor
                                new-neighbors)
                        (conj seen current-node))))))))))


(defn bfs-from-1 [graph queue min-weight predecessor depth]
  (lazy-seq
   (if (empty? queue)
     (list)
     (if (depth (first queue))
       (bfs-from-1 graph
                   (pop queue)
                   min-weight
                   predecessor
                   depth)
       (let [this-node (first queue)
             this-depth (if-let [pred-depth (depth (predecessor this-node))]
                          (+ 1 pred-depth)
                          0)
             new-neighbors (filter (fn [neighbor]
                                     (and (not (depth neighbor))
                                          (not (= neighbor this-node))))
                                   (neighbors graph this-node min-weight))]
         (cons {:node this-node
                :tag (tag-for graph this-node)
                :predecessor (predecessor this-node)
                :depth this-depth}
               (bfs-from-1 graph
                           (into (pop queue) new-neighbors)
                           min-weight
                           (reduce (fn [acc neigh]
                                     (assoc acc neigh this-node))
                                   predecessor
                                   new-neighbors)
                           (assoc depth this-node this-depth))))))))

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

(defn all-paths-1 [graph src dest min-weight max-depth exclude]
  (if (<= max-depth 1)
    (if (seq (->> (neighbors graph src min-weight)
                  (filter #(= dest %))))
      (list (list (make-path-node graph src)
                  (make-path-node graph dest)))
      (list))
    (->> (neighbors graph src min-weight)
         (filter (complement exclude))
         (mapcat #(all-paths-1 graph
                               %1
                               dest
                               min-weight
                               (dec max-depth)
                               (conj exclude %1)))
         (map #(conj % (make-path-node graph src))))))

(defn all-paths
  "Returns all distinct paths between src and dest. Returned nodes are of the form
   {:node node, :tag tag-for-node}. :tag will be nil if no tag was set.
   Optional parameter min-weight reflects which edges are considered valid."
  ([graph src dest]
     (all-paths graph src dest 0))
  ([graph src dest min-weight]
     (all-paths-1 graph
                  src
                  dest
                  min-weight
                  (dec (count (path graph src dest min-weight)))
                  (hash-set src))))

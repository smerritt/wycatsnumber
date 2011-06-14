(ns org.andcheese.wycatsnumber.util)

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



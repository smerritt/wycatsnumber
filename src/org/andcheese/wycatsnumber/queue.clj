(ns org.andcheese.wycatsnumber.queue)

(defn vacant [] [])

(defn add [queue items]
  (reduce (fn [acc item]
            (conj acc item))
          queue
          items))

(defn dequeue [queue]
  [(queue 0)
   (subvec queue 1)])

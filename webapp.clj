(ns wycatsnumber)
(require '[clj-yaml.core :as yaml])

(yaml/parse-string (slurp "config/database.yml"))


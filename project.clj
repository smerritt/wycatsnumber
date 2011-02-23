(defproject wycatsnumber "0.0.1"
  :description "Find a shortest path between two devs as measured by Github commits"
  :url "https://github.com/smerritt/wycatsnumber"
  :source-path "src"
  :dependencies [[org.clojure/clojure "1.2.0"]
                 [org.clojure/clojure-contrib "1.2.0"]
                 [clj-yaml "0.3.0-SNAPSHOT"]
                 [compojure "0.5.2"]
                 [org.clojars.rnewman/ring "0.2.2-sessions"]
                 [postgresql/postgresql "9.0-801.jdbc4"]
                 [org.danlarkin/clojure-json "1.2-SNAPSHOT"]]
  :dev-dependencies [[swank-clojure "1.2.1"]
                     [uk.org.alienscience/leiningen-war "0.0.12"]]
  :jvm-opts ["-Xmx384m"])

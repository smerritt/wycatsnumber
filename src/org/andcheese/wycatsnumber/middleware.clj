(ns org.andcheese.wycatsnumber.middleware)

(defn jsonp-ify [handler]
  "If the response is JSON and the request contains the 'callback' parameter
  wraps the response body, e.g. \"$callback($response)\")"
  (fn [request]
    (if-let [jsonp (get-in request
                           [:query-params "callback"])]
      (let [response (handler request)]
        (if (= "application/json"
               (get-in response [:headers "Content-Type"]))
          (-> response
              (assoc :body (str jsonp "(" (response :body) ");"))
              (update-in [:headers "Content-Type"] (constantly "application/javascript")))
          response))
      (handler request))))


(defn remove-context [handler]
  "Strips the servlet-context part out of the request map
   so that your routes still work when deployed in a
   servlet container.

  Does nothing to help you generate self-referential links."
  (fn [request]
    (if-let [context (:context request)]
      (let [uri (:uri request)]
        (if (.startsWith uri context)
          (let [minus-context (.substring uri
                                          (.length context))
                uri-minus-context (if (= "" minus-context)
                                    "/"
                                    minus-context)]
            (handler (assoc request
                       :uri uri-minus-context)))
          (handler request)))
      (handler request))))

(defn print-request [handler]
  "Prints the request, then forwards it.
   No changes to the request or the response."
  (fn [request]
    (println request)
    (handler request)))

(defn print-response [handler]
  "Prints the response, then returns it.
   No changes to the request or the response."
  (fn [request]
    (let [response (handler request)]
      (println response)
      response)))


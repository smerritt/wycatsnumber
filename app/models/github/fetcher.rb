module Github
  module Fetcher

    def fetch_and_retry(url)
      Log.debug "Fetching #{url}"
      retry_count = 0

      begin
        result = RestClient.get(url)
        Log.debug "Fetching #{url} successful"
        result
      rescue RestClient::ResourceNotFound
        nil
      rescue RestClient::Unauthorized, RestClient::Forbidden, Errno::ETIMEDOUT => e
        if retry_count > 100
          raise e
        end

        retry_count += 1
        t = sleep_time(retry_count)
        Log.debug "Fetching #{url} hit rate limiter; will retry in #{t}s"
        sleep t
        retry
      end
    end

    # bounded random exponential backoff, maximum 1024 seconds
    def sleep_time(retries)
      rand(2**[10,retries].min)
    end

  end
end

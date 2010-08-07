module Github
  module Fetcher

    def fetch_and_retry(url)
      retry_count = 0

      begin
        RestClient.get(url)
      rescue RestClient::ResourceNotFound
        nil
      rescue RestClient::Unauthorized, RestClient::Forbidden, Errno::ETIMEDOUT => e
        if retry_count > 100
          raise e
        end
        # puts "Got #{e.inspect}; going to retry"
        retry_count += 1
        sleep sleep_time(retry_count)
        retry
      end
    end

    # bounded random exponential backoff, maximum 1024 seconds
    def sleep_time(retries)
      rand(2**[10,retries].min)
    end

  end
end

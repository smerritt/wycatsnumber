module Github
  module Fetcher

    def self.included(klass)
      klass.extend(ClassMethods)
    end

    def fetch_and_retry(path)
      self.class.fetch_and_retry(path)
    end

    def sleep_time(retries)
      self.class.sleep_time(retries)
    end

    module ClassMethods
      def fetch_and_retry(path)
        retry_count = 0
        Github::Fetcher.randomize_endpoints

        begin
          url = Github::Fetcher.first_endpoint + path

          Log.debug "Fetching #{url}"
          result = RestClient.get(url, :host => 'github.com')
          Log.debug "Fetching #{url} successful"
          result
        rescue RestClient::ResourceNotFound
          nil
        rescue Errno::ECONNREFUSED
          Log.debug "Fetching #{url} got ECONNREFUSED; rotating endpoints and trying again immediately"
          Github::Fetcher.rotate_endpoints
          retry
        rescue RestClient::Unauthorized, RestClient::Forbidden, Errno::ETIMEDOUT => e
          if retry_count > 10
            raise e
          end

          retry_count += 1

          # first time through, just rotate and try again
          #
          # subsequent retries, back off; more than one endpoint may
          # have hit the limiter, and we don't want to annoy github
          # too much.
          #
          # alternately, we may have just one endpoint, and the
          # rotate-and-try-again strategy will do nothing but
          # continuously hammer our one endpoint and ensure we never
          # make progress.
          Github::Fetcher.rotate_endpoints
          if retry_count == 1
            Log.debug "Fetching #{url} hit rate limiter; rotating endpoints and trying again immediately"
          else
            t = sleep_time(retry_count)
            Log.debug "Fetching #{url} hit rate limiter; will retry in #{t}s"
            sleep t
          end
          retry
        end
      end

      # bounded random exponential backoff, maximum 90 seconds
      def sleep_time(retries)
        [rand(2**[10,retries].min), 90].min
      end
    end

    def self.endpoints=(es)
      @endpoints = es
    end

    endpoints = ['http://github.com']

    def self.rotate_endpoints
      @endpoints << @endpoints.shift
    end

    def self.randomize_endpoints
      @endpoints = @endpoints.sort_by { rand }
    end

    def self.first_endpoint
      @endpoints.first
    end



  end
end

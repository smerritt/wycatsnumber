module Github
  class Repo < Struct.new(:name, :fork)

    alias :fork? :fork

    def users
      @users ||= contributors_data.map do |contributor|
        contributor["login"]
      end.map do |github_username|
        Github::User.new(github_username)
      end
    end

    private

    def contributors_data
      response = fetch_and_retry(contributors_url)
      JSON.parse(response.body)["contributors"]
    end

    def contributors_url
      "http://github.com/api/v2/json/repos/show/#{name}/contributors"
    end

    def fetch_and_retry(url)
      retry_count = 0

      begin
        RestClient.get(url)
      rescue RestClient::ResourceNotFound
        nil
      rescue RestClient::Unauthorized, Errno::ETIMEDOUT => e
        if retry_count > 100
          raise e
        end
        # puts "Got #{e.inspect}; going to retry"
        retry_count += 1
        sleep sleep_time(retry_count)
        retry
      end
    end

    def sleep_time(retries)
      rand(2**[10,retries].min)
    end

  end
end

module Github
  class User < Struct.new(:name)

    def repos
      response = fetch_and_retry("http://github.com/api/v2/json/repos/show/#{name}")
      @repos ||= JSON.parse(response.body)["repositories"].map do |repo_data|
        Github::Repo.new(repo_data["name"], repo_data["fork"])
      end
    end

    private

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

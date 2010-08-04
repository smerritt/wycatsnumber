module Github
  class Repo < Struct.new(:name, :fork)

    alias :fork? :fork

    def users
      @users ||= commits.map do |commit|
        commit["author"]["login"]
      end.find_all do |github_username|
        github_username && github_username.length > 0
      end.uniq.map do |github_username|
        Github::User.new(github_username)
      end
    end

    private

    def commits
      return @commits if @commits

      page = 1
      @commits = []
      while response = fetch_and_retry(commits_page(page)) do
        @commits += JSON.parse(response.body)["commits"]
        page += 1
      end

      @commits
    end

    def commits_page(page)
      # puts "fetching page #{page}"
      "http://github.com/api/v2/json/commits/list/#{name}/master?page=#{page}"
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

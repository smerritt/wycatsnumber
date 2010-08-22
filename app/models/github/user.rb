module Github
  class User < Struct.new(:name, :gravatar_id)
    include Fetcher

    def owned_repos
      response = fetch_and_retry(owned_repos_path)
      @owned_repos ||= JSON.parse(response.body)["repositories"].map do |repo_data|
        Github::Repo.from_api_repo(repo_data)
      end
    end

    def unowned_watched_repos
      watched_repos.find_all do |repo|
        repo.owner != self.name
      end
    end

    def watched_repos
      response = fetch_and_retry(watched_repos_path)
      @watched_repos ||= JSON.parse(response.body)["repositories"].map do |repo_data|
        Github::Repo.from_api_repo(repo_data)
      end
    end

    private

    def owned_repos_path
      "/api/v2/json/repos/show/#{name}"
    end

    def watched_repos_path
      "/api/v2/json/repos/watched/#{name}"
    end

  end
end

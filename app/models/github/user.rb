module Github
  class User < Struct.new(:name, :gravatar_id)
    include Fetcher

    def owned_repos
      response = fetch_and_retry(owned_repos_path)
      @owned_repos ||= JSON.parse(response.body)["repositories"].map do |repo_data|
        Github::Repo.from_api_repo(repo_data)
      end
    end

    private

    def owned_repos_path
      "/api/v2/json/repos/show/#{name}"
    end

  end
end

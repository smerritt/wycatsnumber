module Github
  class User < Struct.new(:name, :gravatar_id)
    include Fetcher

    def repos
      response = fetch_and_retry(repos_path)
      @repos ||= JSON.parse(response.body)["repositories"].map do |repo_data|
        Github::Repo.from_api_repo(repo_data)
      end
    end

    private

    def repos_path
      "/api/v2/json/repos/show/#{name}"
    end

  end
end

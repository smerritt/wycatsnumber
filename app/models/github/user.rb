module Github
  class User < Struct.new(:name, :gravatar_id)
    include Fetcher

    def repos
      response = fetch_and_retry(repos_url)
      @repos ||= JSON.parse(response.body)["repositories"].map do |repo_data|
        Github::Repo.new(repo_data["name"], repo_data["fork"])
      end
    end

    private

    def repos_url
      "http://github.com/api/v2/json/repos/show/#{name}"
    end

  end
end

module Github
  class User < Struct.new(:name)

    def repos
      response = RestClient.get("http://github.com/api/v2/json/repos/show/#{name}")
      @repos ||= JSON.parse(response.body)["repositories"].map do |repo_data|
        Github::Repo.new(repo_data["name"], repo_data["fork"])
      end
    end

  end
end

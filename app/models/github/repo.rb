module Github
  class Repo < Struct.new(:name, :fork)

    alias :fork? :fork

    def users
      commits.map do |commit|
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
      while(page) do
        begin
          response = RestClient.get(
            "http://github.com/api/v2/json/commits/list/#{name}/master?page=#{page}"
            )
          @commits += JSON.parse(response.body)["commits"]
          page += 1
        rescue RestClient::ResourceNotFound
          page = nil
        end
      end

      @commits
    end

  end
end

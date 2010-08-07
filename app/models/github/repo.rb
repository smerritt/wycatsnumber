module Github
  class Repo < Struct.new(:name, :fork)
    include Fetcher

    alias :fork? :fork

    def users
      @users ||= contributors_data.map do |contributor|
        Github::User.new(contributor["login"], contributor["gravatar_id"])
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

  end
end

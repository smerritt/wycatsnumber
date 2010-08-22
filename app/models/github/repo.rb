module Github
  class Repo < Struct.new(:name, :parent_name)
    include Fetcher

    def fork?
      !parent_name.nil?
    end

    def owner
      name.split(/\//).first
    end

    def self.fetch(name)
      api_response = fetch_and_retry(base_path(name))
      if api_response    # 404 --> nil
        from_api_repo(JSON.parse(api_response)["repository"])
      end
    end

    def self.from_api_repo(api_repo)
      new("%s/%s" % [api_repo["owner"], api_repo["name"]], api_repo["parent"])
    end

    def users
      @users ||= contributors_data.map do |contributor|
        Github::User.new(contributor["login"], contributor["gravatar_id"])
      end
    end

    private

    def contributors_data
      response = fetch_and_retry(contributors_path)
      JSON.parse(response.body)["contributors"]
    end

    def self.base_path(name)
      "/api/v2/json/repos/show/#{name}"
    end

    def base_path
      self.class.base_path(self.name)
    end

    def contributors_path
      base_path + "/contributors"
    end
  end
end

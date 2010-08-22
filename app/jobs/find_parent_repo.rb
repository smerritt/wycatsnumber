class FindParentRepo
  def self.queue() :find_parent_repo end

  def self.perform(repo_name)
    return if repo_name.nil? || repo_name.empty?

    Log.info("Finding parent of #{repo_name}")
    if Fork.get repo_name
      Log.info "#{repo_name} is a fork we've seen before; skipping"
      return
    else
      Fork.create(:name => repo_name)
    end

    repo = Github::Repo.fetch(repo_name)
    unless repo
      Log.info("Repository #{repo_name} does not exist; ignoring")
      return
    end

    if repo.fork?
      Log.info("Repository #{repo_name} is a fork of #{repo.parent_name}")
      Resque.enqueue(self, repo.parent_name)
    else
      Log.info("Repository #{repo_name} is not a fork")
      Resque.enqueue(WalkRepo, repo_name)
    end
  end
end

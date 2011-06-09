class WalkUser
  def self.queue() :walk_user end

  def self.perform(username)
    return if username.nil? || username.empty?

    user = Github::User.new(username)
    author = Author.first(:github_username => username)
    return unless author.needs_fetch?

    Log.info "walking user #{username}"
    (user.owned_repos + user.unowned_watched_repos).each do |repo|
      if repo.fork?
        consider_fork(repo)
      else
        consider_repo(repo)
      end
    end
    author.fetched!
  end

  def self.consider_fork(repo)
    Log.info "enqueuing FindParentRepo(#{repo.name})"
    Resque.enqueue(FindParentRepo, repo.name)
  end

  def self.consider_repo(repo)
    if !(p = Project.first(:name => repo.name)) || p.needs_fetch?
      Log.info "enqueuing WalkRepo(#{repo.name})"
      Resque.enqueue(WalkRepo, repo.name)
    else
      Log.info "Project (#{repo.name}) is fresh; skipping"
    end
  end

end

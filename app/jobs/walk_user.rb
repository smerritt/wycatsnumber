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
        Log.info "enqueuing FindParentRepo(#{repo.name})"
        Resque.enqueue(FindParentRepo, repo.name)
      else
        Log.info "enqueuing WalkRepo(#{repo.name})"
        Resque.enqueue(WalkRepo, repo.name)
      end
    end
    author.fetched!
  end

end

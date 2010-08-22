class WalkUser
  def self.queue() :walk_user end

  def self.perform(username)
    user = Github::User.new(username)

    (user.owned_repos + user.unowned_watched_repos).each do |repo|
      if repo.fork?
        Resque.enqueue(FindParentRepo, repo.name)
      else
        Resque.enqueue(WalkRepo, repo.name)
      end
    end
  end

end

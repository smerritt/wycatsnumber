class WalkUser
  def self.queue() :walk_user end

  def self.perform(username)
    Github::User.new(username).repos.find_all do |repo|
      if repo.fork?
        Resque.enqueue(FindParentRepo, repo.name)
      else
        Resque.enqueue(WalkRepo, repo.name)
      end
    end
  end

end

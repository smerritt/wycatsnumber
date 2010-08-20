class WalkUser
  def self.queue() :walk_user end

  def self.perform(username)
    Github::User.new(username).repos.find_all do |repo|
      !repo.fork?
    end.each do |repo|
      Resque.enqueue(WalkRepo, "#{username}/#{repo.name}")
    end
  end

end

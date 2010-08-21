class FindParentRepo
  def self.queue() :find_parent_repo end

  def self.perform(repo_name)
    repo = Github::Repo.fetch(repo_name)
    if repo.fork?
      Resque.enqueue(self, repo.parent_name)
    else
      Resque.enqueue(WalkRepo, repo_name)
    end
  end
end

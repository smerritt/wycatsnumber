class FindParentRepo
  def self.queue() :find_parent_repo end

  def self.perform(repo_name)
    repo = Github::Repo.fetch(repo_name)
    return unless repo

    if repo.fork?
      Resque.enqueue(self, repo.parent_name)
    else
      Resque.enqueue(WalkRepo, repo_name)
    end
  end
end

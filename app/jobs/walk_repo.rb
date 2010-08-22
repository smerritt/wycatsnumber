class WalkRepo
  def self.queue() :walk_repo end

  def self.perform(repo_name)
    return if repo_name.nil? || repo_name.empty?

    if Project.first(:name => repo_name)
      Log.info "Project #{repo_name} already exists; skipping"
      return
    end
    DataMapper.repository do
      _perform(repo_name)
    end
  end

  def self._perform(repo_name)
    Log.info("walking #{repo_name}")
    project = Project.create(:name => repo_name)

    authors = Github::Repo.new(repo_name).users.map do |user|
      if a = Author.from_github_user(user)
        a
      else
        a = Author.create_from_github_user(user)
        walk_user_later(user)
        a
      end
    end

    project.update_authors(authors)
  end

  private
  def self.walk_user_later(user)
    Resque.enqueue(WalkUser, user.name)
  end

end

class WalkRepo
  def self.queue() :walk_repo end

  def self.perform(repo_name)
    return if repo_name.nil? || repo_name.empty?

    project = Project.first(:name => repo_name) ||
      Project.create(:name => repo_name)

    unless project.needs_fetch?
      Log.info "Project #{repo_name} has been fetched recently; skipping"
      return
    end

    DataMapper.repository do
      _perform(project)
    end
  end

  def self._perform(project)
    Log.info("walking #{project.name}")

    Github::Repo.new(project.name).contributors.map do |(user, commit_count)|
      author = if a = Author.from_github_user(user)
                 consider_walking_user(user)
                 a
               else
                 a = Author.create_from_github_user(user)
                 consider_walking_user(user)
                 a
               end
      author.worked_on(project, commit_count)
    end

    project.fetched!
  end

  private
  def self.consider_walking_user(user)
    if !(a = Author.first(:github_username => user.name)) || a.needs_fetch?
      Log.info("enqueuing WalkUser(#{user.name})")
      Resque.enqueue(WalkUser, user.name)
    else
      Log.info("Author #{user.name} is fresh; skipping")
    end
  end

end

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
                 a
               else
                 a = Author.create_from_github_user(user)
                 walk_user_later(user)
                 a
               end
      author.worked_on(project, commit_count)
    end

    project.fetched!
  end

  private
  def self.walk_user_later(user)
    Resque.enqueue(WalkUser, user.name)
  end

end

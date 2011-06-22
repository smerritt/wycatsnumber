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
      author = Author.from_github_user(user) ||
        Author.create_from_github_user(user)

      if author
        consider_walking(author)
        author.worked_on(project, commit_count)
      end
    end

    project.fetched!
  end

  private
  def self.consider_walking(author)
    if author.needs_fetch?
      Log.info("enqueuing WalkUser(#{author.github_username})")
      Resque.enqueue(WalkUser, author.github_username)
    else
      Log.info("Author #{author.github_username} is fresh; skipping")
    end
  end

end

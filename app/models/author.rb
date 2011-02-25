class Author
  include DataMapper::Resource

  COMMIT_RANGE = 1..12

  property :id,              Serial
  property :github_username, String,  :required => true, :length => 255, :index => true
  property :gravatar_id,     String
  property :fetched_at,      DateTime

  has n, :collaborations
  has n, :projects,            :through => :collaborations

  # This should be an association, but instead here I am working
  # around a DM bug.
  #
  # At least it's still one query.
  def neighbors
    Author.all(:collaborations => projects.collaborations, :id.not => id)
  end

  def self.from_github_user(user)
    first(:github_username => user.name)
  end

  def self.create_from_github_user(user)
    Log.info("creating user #{user.name}")
    create(:github_username => user.name, :gravatar_id => user.gravatar_id)
  end

  def needs_fetch?
    !fetched_at || (Time.now - fetched_at.to_time >= 60*60*24*7)   # at least a week old
  end

  def fetched!
    update(:fetched_at => Time.now)
  end

  def collaboration_for(project)
    collaborations.first(:project => project)
  end

  def worked_on(project, commit_count)
    if c = collaboration_for(project)
      c.update(:commits => commit_count)
    else
      collaborations.create(:project => project, :commits => commit_count)
    end
  end

  def predecessor(source_author, min_commits)
    if pr = Predecession.first(
        :from => self,
        :to   => source_author,
        :commits => min_commits)
      pr.predecessor
    end
  end

end

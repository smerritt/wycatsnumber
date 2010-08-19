class Author
  include DataMapper::Resource

  INFINITE_DISTANCE = 2**31 - 1

  property :id,              Serial
  property :github_username, String,  :required => true
  property :gravatar_id,     String
  property :distance,        Integer, :required => true, :default => INFINITE_DISTANCE

  has n, :collaborations
  has n, :projects,            :through => :collaborations

  validates_with_block :distance do
    [distance && distance >= 0, "Distance must be non-negative"]
  end

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
    create(:github_username => user.name, :gravatar_id => user.gravatar_id)
  end

  def path_to_origin
    if distance == 0
      []
    elsif pred = predecessor
      [[projects_for(pred).first, pred]] + pred.path_to_origin
    else
      []
    end
  end

  def projects_for(other)
    return nil unless other
    self.collaborations(:author => other).projects
  end

  def nearer_neighbors
    neighbors.all(:distance => self.distance - 1)
  end

  def predecessor
    nearer_neighbors.first
  end

  def further_neighbors
    neighbors.all(:distance.gt => self.distance)
  end

  def neighbor_got_closer(neighbor)
    if neighbor.distance < self.distance - 1
      update(:distance => neighbor.distance + 1)
      further_neighbors.each do |fn|
        fn.neighbor_got_closer(self)
      end
    end
  end

end

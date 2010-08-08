class Author
  include DataMapper::Resource

  INFINITE_DISTANCE = 2**31 - 1

  property :id,              Serial
  property :github_username, String,  :required => true
  property :gravatar_id,     String
  property :distance,        Integer, :required => true, :default => INFINITE_DISTANCE

  has n, :collaborations
  has n, :projects,            :through => :collaborations
  has n, :neighbors,     self, :through => :projects, :via => :author

  validates_with_block :distance do
    [distance && distance >= 0, "Distance must be non-negative"]
  end


  def self.from_github_user(user)
    first(:github_username => user.name)
  end

  def self.create_from_github_user(user)
    create(:github_username => user.name, :gravatar_id => user.gravatar_id)
  end


  def worked(args)
    debugger if $debug

    with = args[:with] or raise ArgumentError, ":with is a required argument"
    on   = args[:on]   or raise ArgumentError, ":on is a required argument"

    self.add_collaboration(with, on)
    with.add_collaboration(self, on)
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

  protected

  def add_collaboration(other, project)

    if self.distance > other.distance + 1
      update(:distance => other.distance + 1)
      further_neighbors.each do |fn|
        fn.neighbor_got_closer(self)
      end
    end

    c = Collaboration.first_or_create(:author => self, :project => project)
    c.valid? or raise "FAIL: #{c.errors.inspect}"
    c
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

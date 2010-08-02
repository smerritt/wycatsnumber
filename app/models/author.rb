class Author
  include DataMapper::Resource

  INFINITE_DISTANCE = 2**31 - 1

  property :id,              Serial
  property :github_username, String,  :required => true
  property :distance,        Integer, :required => true, :default => INFINITE_DISTANCE

  has n, :collaborations,  :child_key => [:source_id]
  has n, :neighbors, self, :through => :collaborations, :via => :target

  validates_with_block :distance do
    [distance && distance >= 0, "Distance must be non-negative"]
  end

  def worked(args)
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
      self.distance = other.distance + 1
      further_neighbors.each do |fn|
        fn.neighbor_got_closer(self)
      end
    end

    c = Collaboration.first_or_create(:source => self, :target => other, :project => project)
    c.valid? or raise "FAIL: #{c.errors.inspect}"
    c
  end

  def projects_for(other)
    return nil unless other
    self.collaborations(:target => other).projects
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

class Project
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :length => 255, :index => true

  has n, :collaborations
  has n, :authors, :through => :collaborations

  def update_authors(authors)
    update(:authors => authors) or raise "Failed to save #{self}"
    closest = authors.min {|a,b| a.distance <=> b.distance}

    getting_closer = authors.find_all do |a|
      a.distance > closest.distance + 1
    end

    until getting_closer.empty?
      author = getting_closer.pop
      author.relax
      getting_closer += author.too_far_neighbors.find_all {|a| !getting_closer.include?(a)}
    end
  end

end

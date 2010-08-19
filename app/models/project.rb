class Project
  include DataMapper::Resource

  property :id,   Serial
  property :name, String

  has n, :collaborations
  has n, :authors, :through => :collaborations

  def update_authors(authors)
    update(:authors => authors) or raise "Failed to save #{self}"
    closest = authors.min {|a,b| a.distance <=> b.distance}
    if closest
      authors.find_all do |a|
        a.distance > closest.distance + 1
      end.each do |a|
        a.neighbor_got_closer(closest)
      end
    end
  end

end

class Project
  include DataMapper::Resource

  property :id,   Serial
  property :name, String

  has n, :collaborations
  has n, :authors, :through => :collaborations
end

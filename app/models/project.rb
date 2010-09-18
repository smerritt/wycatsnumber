class Project
  include DataMapper::Resource

  property :id,   Serial
  property :name, String, :length => 255, :index => true

  has n, :collaborations
  has n, :authors, :through => :collaborations
end

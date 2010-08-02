class Project
  include DataMapper::Resource

  property :id,   Serial
  property :name, String

  # source or target; it doesn't matter which since the relation is symmetric
  # has n, :collaborations
  # has n, :authors, 'Author', :through => :collaborations, :via => :target
end

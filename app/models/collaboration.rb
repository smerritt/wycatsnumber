class Collaboration
  include DataMapper::Resource

  property :id,      Serial
  property :commits, Integer

  belongs_to :author
  belongs_to :project
end

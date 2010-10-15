class Collaboration
  include DataMapper::Resource

  property :id,      Serial
  property :commits, Integer

  property :author_id, Integer
  belongs_to :author

  property :project_id, Integer
  belongs_to :project
end

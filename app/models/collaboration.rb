class Collaboration
  include DataMapper::Resource

  property :id, Serial

  belongs_to :author
  belongs_to :project
end

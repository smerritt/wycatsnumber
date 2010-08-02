class Collaboration
  include DataMapper::Resource

  property :id, Serial

  belongs_to :source, 'Author'
  belongs_to :target, 'Author'
  belongs_to :project
end

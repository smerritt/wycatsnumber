class Predecession
  include DataMapper::Resource

  property :id,      Serial
  property :commits, Integer

  belongs_to :from,        'Author', :child_key => [:from_id]
  belongs_to :to,          'Author', :child_key => [:to_id]
  belongs_to :predecessor, 'Author', :child_key => [:predecessor_id]
  belongs_to :project
end

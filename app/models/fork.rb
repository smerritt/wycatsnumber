class Fork
  include DataMapper::Resource

  property :name, String, :required => true, :index => true, :key => true
end

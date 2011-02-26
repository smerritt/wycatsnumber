class Project
  include DataMapper::Resource

  MIN_AGE_FOR_FETCH = 60*60*24*7   # one week old

  property :id,         Serial
  property :name,       String, :length => 255, :index => true
  property :fetched_at, DateTime

  has n, :collaborations
  has n, :authors, :through => :collaborations

  def needs_fetch?
    !fetched_at || (Time.now - fetched_at.to_time >= MIN_AGE_FOR_FETCH)
  end

  def fetched!
    update(:fetched_at => Time.now)
  end
end

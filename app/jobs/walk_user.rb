class WalkUser
  def self.queue() :walk_user end

  def perform(username)
    puts "Walking #{username}"
  end
end

class Author
  include DataMapper::Resource

  COMMIT_RANGE = 1..12

  property :id,              Serial
  property :github_username, String,  :required => true, :length => 255, :index => true
  property :gravatar_id,     String

  has n, :collaborations
  has n, :projects,            :through => :collaborations

  # This should be an association, but instead here I am working
  # around a DM bug.
  #
  # At least it's still one query.
  def neighbors
    Author.all(:collaborations => projects.collaborations, :id.not => id)
  end

  def self.from_github_user(user)
    first(:github_username => user.name)
  end

  def self.create_from_github_user(user)
    Log.info("creating user #{user.name}")
    create(:github_username => user.name, :gravatar_id => user.gravatar_id)
  end

  def collaboration_for(project)
    collaborations.first(:project => project)
  end

  def worked_on(project, commit_count)
    if c = collaboration_for(project)
      c.update(:commits => commit_count)
    else
      collaborations.create(:project => project, :commits => commit_count)
    end
  end

  def predecessor(source_author, min_commits)
    if pr = Predecession.first(
        :from => self,
        :to   => source_author,
        :commits => min_commits)
      pr.predecessor
    end
  end

  def self.update_predecessor_matrix
    COMMIT_RANGE.each do |weight|
      graph = all.inject(Graph.new) do |g, author|
        g.add_node(author.id)
      end

      bucketize(Collaboration.all(:commits.gte => weight)) do |collab|
        collab.project_id
      end.each do |project_id, collabs|
        collabs.each do |left|
          collabs.each do |right|
            unless left == right
              # enough nesting for you?
              graph.add_edge(
                left.author_id,
                right.author_id,
                project_id)
            end
          end
        end
      end

      graph.compute_all_pairs_shortest_path do |author_id, source_id, predecessor_id, project_id|
        if pr = Predecession.first(
            :from_id => author_id,
            :to_id   => source_id,
            :commits => weight)
          pr.update(
            :predecessor_id => predecessor_id,
            :project_id     => project_id)
        else
          pr = Predecession.create(
            :to_id          => source_id,
            :from_id        => author_id,
            :predecessor_id => predecessor_id,
            :project_id     => project_id,
            :commits        => weight)
          pr.valid? or raise "wtf?: #{pr.errors.inspect}"
        end
      end
    end

  end

  private
  # I could swear that Ruby has this built in, but I can't find it.
  #
  # On a related note, whose bright fucking idea was it to have
  # Enumerable#partition divide things only into true/false
  # partitions?
  def self.bucketize(enum, &block)
    buckets = Hash.new {|h,k| h[k] = []}
    enum.each do |element|
      buckets[block.call(element)] << element
    end
    buckets
  end

end

class Graph
  INFINITE_DISTANCE = 2**31 - 1

  def initialize
    @nodes = []
    @edges = Hash.new{|h,k| h[k] = []}
    @extra_data = Hash.new{|h,k| h[k] = {}}
  end

  def add_node(node)
    if @nodes.include?(node)
      raise ArgumentError, "Tried to add duplicate node #{node.inspect}"
    end
    @nodes << node
    self
  end

  def add_edge(left_node, right_node, extra_data)
    unless @nodes.include?(left_node)
      raise ArgumentError, "Unknown node #{left_node}"
    end
    unless @nodes.include?(right_node)
      raise ArgumentError, "Unknown node #{right_node}"
    end

    @edges[left_node] << right_node
    @extra_data[left_node][right_node] = extra_data
    self
  end

  def neighbors(node)
    @edges[node]
  end

  def compute_all_pairs_shortest_path
    raise ArgumentError, "Needs a block" unless block_given?

    # Dijkstra's algorithm for each node
    # It's okay-ish for positive-edge-weight graphs.
    @nodes.each do |source|
      distance = Hash.new(INFINITE_DISTANCE)
      distance[source] = 0

      predecessor = {}

      unvisited = @nodes.dup
      while ! unvisited.empty?
        # SLOW: store unvisited as a min-heap for speed
        current = unvisited.min {|a,b| distance[a] <=> distance[b]}
        neighbors(current).each do |neighbor|
          tentative_distance = distance[current] + 1
          present_distance = distance[neighbor]
          if tentative_distance < present_distance
            distance[neighbor] = tentative_distance
            predecessor[neighbor] = current
          end

        end

        unvisited -= [current]
      end

      @nodes.each do |node|
        if pred = predecessor[node]
          yield node, source, pred, @extra_data[node][pred]
        end
      end

    end
  end

end

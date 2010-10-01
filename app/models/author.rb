class Author
  include DataMapper::Resource

  COMMIT_RANGE = 1..12

  property :id,              Serial
  property :github_username, String,  :required => true, :length => 255, :index => true
  property :gravatar_id,     String
  property :fetched_at,      DateTime

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

  def needs_fetch?
    !fetched_at || (Time.now - fetched_at.to_time >= 60*60*24*7)   # at least a week old
  end

  def fetched!
    update(:fetched_at => Time.now)
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
      all_authors = all.to_a
      all_projects = Project.all.to_a

      graph = all_authors.inject(Graph.new) do |g, author|
        g.add_node(node_id_from_author_id(author.id))
      end

      graph = all_projects.inject(graph) do |g, project|
        g.add_node(node_id_from_project_id(project.id))
      end

      Collaboration.all(:commits.gte => weight).each do |collab|
        graph.add_edge(
          node_id_from_author_id(collab.author_id),
          node_id_from_project_id(collab.project_id))
        graph.add_edge(
          node_id_from_project_id(collab.project_id),
          node_id_from_author_id(collab.author_id))
      end

      all_authors.each do |goal|
        upstream_author_id = {}

        graph.find_shortest_paths(node_id_from_author_id(goal.id)).sort do |a, b|
          # NB: the graph is constructed in such a way that all the
          # edges are between a project and an author, so we need not
          # check a.last and b.last here
          if project_id?(a.first) && author_id?(b.first)
            -1
          elsif author_id?(a.first) && project_id?(b.first)
            1
          else
            0
          end
        end.each do |(node_id, predecessor_id)|
          if project_id?(node_id)
            # node is a project, predecessor an author
            upstream_author_id[project_id_from_node_id(node_id)] =
              author_id_from_node_id(predecessor_id)
          else
            # predecessor is a project, node an author
            further_author_id = author_id_from_node_id(node_id)
            project_id = project_id_from_node_id(predecessor_id)

            # since we've sorted the edges so that (project -> author)
            # edges come first, this is guaranteed present
            closer_author_id =
              upstream_author_id[project_id_from_node_id(predecessor_id)]

            # XXX please make this something like
            # Predecession.set_entry(...)
            if pr = Predecession.first(
                :to      => goal,
                :from_id => further_author_id,
                :commits => weight)
              pr.update(
                :predecessor_id => closer_author_id,
                :project_id     => project_id) or raise "update wtf?: #{pr.errors.inspect}"
            else
              pr = Predecession.create(
                :to             => goal,
                :from_id        => further_author_id,
                :commits        => weight,
                :predecessor_id => closer_author_id,
                :project_id     => project_id)
              pr.valid? or raise "create wtf?: #{pr.errors.inspect}"
            end
          end
        end
      end
    end
  end

  private
  def self.author_id?(id)  id > 0 end
  def self.project_id?(id) id < 0 end

  def self.node_id_from_author_id(id)   id end
  def self.node_id_from_project_id(id) -id end

  def self.author_id_from_node_id(id)   id end
  def self.project_id_from_node_id(id) -id end

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
    # tried making these objects; it results in either really really
    # slow hashing (seconds per object on a 100-node graph!) or it
    # complicates the data by making you track things by ID in data
    # structures instead of just using the thing as a hash key.
    #
    # so yes, this is C-smelling, but on the other hand, this will
    # finish in your lifetime on a reasonable-size graph.
    @nodes = []
    @edges = Hash.new{|h,k| h[k] = []}
  end

  def add_node(node)
    if @nodes.include?(node)
      raise ArgumentError, "Tried to add duplicate node #{node.inspect}"
    end
    @nodes << node
    self
  end

  def add_edge(left_node, right_node)
    unless @nodes.include?(left_node)
      raise ArgumentError, "Unknown node #{left_node}"
    end
    unless @nodes.include?(right_node)
      raise ArgumentError, "Unknown node #{right_node}"
    end

    @edges[left_node] << right_node
    self
  end

  def neighbors(node)
    @edges[node]
  end

  def find_shortest_paths(source)
    # Plain old Dijkstra's algorithm
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

    @nodes.map do |node|
      if pred = predecessor[node]
        [node, pred]
      end
    end.compact
  end

end

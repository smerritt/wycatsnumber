class MinHeap

  # I was unable to find a gem that just gives me a simple min-heap.
  #
  # priority_queue uses the thread-safe Queue class, and is just a
  # thin wrapper around a hash of (priority, Queue) pairs; getting the
  # next element sorts that hash by priority each time, so it's
  # O(N log N), and thus even worse than scanning an array.
  #
  # PriorityQueue is rather a lot of code for such a simple thing, and
  # it's full of code like "@min.key rescue nil", which makes my teeth
  # itch. Who knows what sort of things are getting masked by that
  # "rescue nil"?
  #
  # Also, this is a fun weekend project, and writing a heap is fun.

  class Item < Struct.new(:key, :value); end  # just syntactic sugar

  def initialize(starting_items = {})
    @index_of = {}
    @items = []
    starting_items.each do |k,v|
      self[k] = v
    end
  end

  def empty?
    @items.empty?
  end

  def [](key)
    index = @index_of[key]

    if index
      @items[index].value
    end
  end

  def []=(key, value)
    if self[key]
      decrease_key(key, value)
    else
      add(key, value)
    end
    value
  end

  def pop_key
    pop.first
  end

  def pop
    min = @items[0]
    @index_of.delete(min.key)
    if @items.size > 1
      @items[0] = @items.pop
      @index_of[@items[0].key] = 0
      heapify(0)
    else
      @items.pop
    end
    [min.key, min.value]
  end

  def size
    @items.size
  end


  private
  # Really handy when you start getting weird results.
  def assert_valid
    @index_of.each do |key, index|
      if @items[index].nil? || @items[index].key != key || @items.size != @index_of.size
        raise "WTF? #{self.pretty_inspect}"
      end
    end
  end

  def left_index(index)
    2*index + 1
  end

  def right_index(index)
    2*index + 2
  end

  def parent_index(index)
    (index - 1) / 2
  end

  def has_left_child?(index)
    @items.size > left_index(index)
  end

  def has_right_child?(index)
    @items.size > right_index(index)
  end

  def add(key, value)
    @items << Item.new(key, value)
    @index_of[key] = @items.size - 1
    heapify(@items.size - 1)
  end

  def decrease_key(key, new_value)
    @items[@index_of[key]].value = new_value
    heapify(@index_of[key])
  end

  def value(index)
    @items[index].value
  end

  def left_child_value(index)
    value(left_index(index))
  end

  def right_child_value(index)
    value(right_index(index))
  end

  def parent_value(index)
    value(parent_index(index))
  end

  def swap(i1, i2)
    @index_of[@items[i1].key], @index_of[@items[i2].key] =
      @index_of[@items[i2].key], @index_of[@items[i1].key]
    @items[i1], @items[i2] =
      @items[i2], @items[i1]
  end

  def lesser_child_index(index)
    if has_lesser_child?(index)
      if has_right_child?(index) && left_child_value(index) > right_child_value(index)
        right_index(index)
      else
        left_index(index)
      end
    end
  end

  def has_lesser_child?(index)
    (has_left_child?(index) && left_child_value(index) < value(index)) ||
      (has_right_child?(index) && right_child_value(index) < value(index))
  end

  def heapify(index)
    if child_index = lesser_child_index(index)
      swap(index, child_index)
      heapify(child_index)
    elsif index > 0 && parent_value(index) > value(index)
      swap(index, parent_index(index))
      heapify(parent_index(index))
    end
  end
end

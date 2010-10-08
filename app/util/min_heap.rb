class MinHeap

  class Item < Struct.new(:key, :value); end

  def initialize(starting_items = {})
    @items = starting_items.map{|k,v| Item.new(k,v) }
  end

  def empty?
    @items.empty?
  end

  def add(key, value)
    @items << Item.new(key, value)
    heapify(@items.size - 1)
  end

  def pop
    min = @items[0].first
    if @items.size > 1
      @items[0] = @items.pop
      heapify(0)
    else
      @items.pop
    end
    min
  end

  def size
    @items.size
  end

  private
  def left_index(index)
    2*index + 1
  end

  def right_index(index)
    2*index + 2
  end

  def parent_index(index)
    index / 2
  end

  def has_left_child?(index)
    @items.size > left_index(index)
  end

  def has_right_child?(index)
    @items.size > right_index(index)
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
    @items[i1], @items[i2] = @items[i2], @items[i1]
  end

  def lesser_child_index(index)
    if has_left_child?(index) && left_child_value(index) < value(index)
      if has_right_child?(index) && left_child_value(index) > right_child_value(index)
        right_index(index)
      else
        left_index(index)
      end
    end
  end

  def heapify(index)
    if child_index = lesser_child_index(index)
      swap(index, child_index)
      heapify(child_index)
    elsif parent_value(index) > value(index)
      swap(index, parent_index(index))
      heapify(parent_index(index))
    end
  end
end

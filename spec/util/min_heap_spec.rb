require File.expand_path('../../spec_helper', __FILE__)

describe MinHeap do
  def pop_all_keys(heap)
    all = []
    until heap.empty?
      all << heap.pop_key
    end
    all
  end

  context "#empty?" do
    it "starts empty" do
      described_class.new.should be_empty
    end

    it "stops being empty when you add things to it" do
      heap = described_class.new
      heap['beer'] = 5
      heap.should_not be_empty
    end

    it "becomes empty again once all its items are removed" do
      heap = described_class.new
      heap['beer'] = 5
      heap.pop
      heap.should be_empty
    end
  end

  context "#size" do
    it "goes up and down as you add and pop items" do
      heap = described_class.new
      heap.size.should == 0

      heap[:a] = 1
      heap.size.should == 1

      heap[:b] = 2
      heap[:c] = 3
      heap.size.should == 3

      heap.pop
      heap.size.should == 2

      heap.pop
      heap.pop
      heap.size.should == 0
    end
  end

  context ".new" do
    it "takes a hash as the heap's starting contents" do
      heap = described_class.new(:a => 1, :b => 2)
      heap.should_not be_empty
    end
  end

  context "#[]" do
    it "retrieves values" do
      heap = described_class.new(:a => 1, :b => 2)
      heap[:a].should == 1
      heap[:b].should == 2
      heap[:z].should == nil
    end
  end

  context "#pop" do
    before(:each) do
      @heap = described_class.new
    end

    it "returns the (key, value) pair with the minimum value" do
      @heap[:a] = 1
      @heap[:b] = 2
      @heap[:c] = 3

      @heap.pop.should == [:a, 1]
      @heap.pop.should == [:b, 2]
      @heap.pop.should == [:c, 3]
    end

    it "returns the key with the minimum value no matter what order things are added in" do
      @heap[:papabear] = 30
      @heap[:babybear] = 2
      @heap[:mamabear] = 28

      pop_all_keys(@heap).should == [:babybear, :mamabear, :papabear]
    end

    it "finds the minimum even when it was added later" do
      10.upto(20) {|i| @heap[i] = i }

      @heap.pop.should == [10, 10]

      @heap[3] = 3
      @heap[2] = 2
      @heap[1] = 1
      @heap.pop.should == [1, 1]
      @heap.pop.should == [2, 2]
      @heap.pop.should == [3, 3]
    end
  end

  context "#pop_key" do
    it "just returns the key, not the value" do
      heap = described_class.new(:a => 1, :b => 2)
      heap.pop_key.should == :a
      heap.pop_key.should == :b
    end
  end

  context "#[]= when decreasing values of existing keys" do
    it "maintains the heap property" do
      heap = described_class.new(
        :a => 100,
        :b => 20,
        :c => 30,
        :d => 40,
        :e => 50,
        :f => 60)

      heap[:a] = 10
      pop_all_keys(heap).should == [:a, :b, :c, :d, :e, :f]
    end
  end

  context "with large numbers of elements" do
    it "continues to work as expected" do
      heap = described_class.new((1..1000).inject({}) do |acc, i|
          acc.merge!(i => i)
        end)

      pop_all_keys(heap).should == (1..1000).to_a
    end
  end

  context "regression tests" do
    it "doesn't get screwy indexes by calling #pop" do
      heap = described_class.new(:a => 1, :b => 2, :c => 3)
      heap.pop

      lambda do
        heap[:b].should == 2
        heap[:c].should == 3
      end.should_not raise_error
    end
  end

end

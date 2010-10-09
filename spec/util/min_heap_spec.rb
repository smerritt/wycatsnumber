require File.expand_path('../../spec_helper', __FILE__)

describe MinHeap do
  def pop_all(heap)
    all = []
    until heap.empty?
      all << heap.pop
    end
    all
  end

  context "#empty?" do
    it "starts empty" do
      described_class.new.should be_empty
    end

    it "stops being empty when you add things to it" do
      heap = described_class.new
      heap.add('beer', 5)
      heap.should_not be_empty
    end

    it "becomes empty again once all its items are removed" do
      heap = described_class.new
      heap.add('beer', 5)
      heap.pop
      heap.should be_empty
    end
  end

  context "#size" do
    it "goes up and down as you add and pop items" do
      heap = described_class.new
      heap.size.should == 0

      heap.add(:a, 1)
      heap.size.should == 1

      heap.add(:b, 2)
      heap.add(:c, 3)
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

  context "#pop" do
    before(:each) do
      @heap = described_class.new
    end

    it "returns the key with the minimum value" do
      @heap.add(:a, 1)
      @heap.add(:b, 2)
      @heap.add(:c, 3)

      @heap.pop.should == :a
      @heap.pop.should == :b
      @heap.pop.should == :c
    end

    it "returns the key with the minimum value no matter what order things are added in" do
      @heap.add(:papabear, 30)
      @heap.add(:babybear, 2)
      @heap.add(:mamabear, 28)

      pop_all(@heap).should == [:babybear, :mamabear, :papabear]
    end

    it "finds the minimum value when it was added later" do
      10.upto(20) {|i| @heap.add(i, i)}

      @heap.pop.should == 10

      @heap.add(3, 3)
      @heap.add(2, 2)
      @heap.add(1, 1)
      @heap.pop.should == 1
      @heap.pop.should == 2
      @heap.pop.should == 3
    end

  end

  context "#decrease_key" do
    it "maintains the heap property" do
      heap = described_class.new(
        :a => 100,
        :b => 20,
        :c => 30,
        :d => 40,
        :e => 50,
        :f => 60)

      heap.decrease_key(:a, 10)
      pop_all(heap).should == [:a, :b, :c, :d, :e, :f]
    end
  end

  context "larger numbers of elements" do
    it "continues to work as expected" do
      heap = described_class.new((1..1000).inject({}) do |acc, i|
          acc.merge!(i => i)
        end)

      pop_all(heap).should == (1..1000).to_a
    end
  end

end

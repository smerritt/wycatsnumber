require File.expand_path('../../spec_helper', __FILE__)

describe Author do
  describe "#valid?" do
    it "requires github_username" do
      Author.make(:github_username => nil).should_not be_valid
    end

    it "requires a distance" do
      Author.make(:distance => nil).should_not be_valid
    end
    
    it "requires a non-negative distance" do
      Author.make(:distance => -1).should_not be_valid
      Author.make(:distance =>  0).should     be_valid
      Author.make(:distance =>  1).should     be_valid
    end
  end
end

describe Author do
  before(:each) do
    @wycats = described_class.gen(:distance => 0, :github_username => 'wycats')

    # ASCII art time:
    #
    #      wycats
    #     /      \
    #    /        \
    # alice      albert
    #   |          |
    #   |          |
    # brenda      bob
    #

    @alice  = described_class.gen(:github_username => 'Alice')
    @brenda = described_class.gen(:github_username => 'Brenda')
    @albert = described_class.gen(:github_username => 'Albert')
    @bob    = described_class.gen(:github_username => 'Bob')

    @alice_project = Project.gen

    @alice.worked( :with => @wycats, :on => @alice_project)
    @brenda.worked(:with => @alice,  :on => Project.gen)
    @albert.worked(:with => @wycats, :on => Project.gen)
    @bob.worked(   :with => @albert, :on => Project.gen)
  end
  
  describe "#worked" do
    it "gets the distances right when building outward from source" do
      @alice.distance.should  == 1
      @brenda.distance.should == 2

      @albert.distance.should == 1
      @bob.distance.should    == 2
    end

    it "propagates distance-shrink information outward" do
      carol = described_class.gen(:github_username => 'Carol')
      debra = described_class.gen(:github_username => 'Debra')
      edna =  described_class.gen(:github_username => 'Edna')
      fran =  described_class.gen(:github_username => 'Fran')

      carol.worked(:with => @brenda, :on => Project.gen)
      carol.worked(:with => debra,   :on => Project.gen)
      debra.worked(:with => edna,    :on => Project.gen)
      edna.worked( :with => fran,    :on => Project.gen)

      fran.distance.should == 6   # sanity check

      fran.worked(:with => @wycats,  :on => Project.gen)
      fran.distance.should  == 1
      edna.reload.distance.should  == 2
      debra.reload.distance.should == 3
    end

    it "doesn't create duplicate collaborations" do
      lambda {
        @alice.worked(:with => @wycats, :on => @alice_project)
      }.should_not change(Collaboration, :count)
    end

  end

end

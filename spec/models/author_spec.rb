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

    @alice_project  = Project.gen(:name => 'alice-project')
    @brenda_project = Project.gen(:name => 'brenda-project')

    @alice_project.update_authors [@wycats, @alice]
    @brenda_project.update_authors [@alice, @brenda]
    Project.gen.update_authors [@wycats, @albert]
    Project.gen.update_authors [@albert, @bob]
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

      Project.gen.update_authors [carol, @brenda]
      Project.gen.update_authors [carol, debra]
      Project.gen.update_authors [debra, edna]
      Project.gen.update_authors [edna, fran]

      fran.distance.should == 6   # sanity check

      Project.gen.update_authors [fran, @wycats]
      fran.distance.should  == 1
      edna.reload.distance.should  == 2
      debra.reload.distance.should == 3
    end
  end

  describe "#path_to_origin" do
    it "is a list of [project, author] pairs leading to the source" do
      pending "need sleep badly"

      @brenda.path_to_origin.should == [
        [@brenda_project, @alice],
        [@alice_project, @wycats],
      ]
    end

    it "is empty for the source" do
      @wycats.path_to_origin.should == []
    end

    it "is empty for unconnected authors" do
      Author.gen.path_to_origin.should == []
    end
  end
end

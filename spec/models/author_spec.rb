require File.expand_path('../../spec_helper', __FILE__)

describe Author do
  before(:each) do
    @albert = described_class.gen(:github_username => 'Albert')
    @project  = Project.gen(:name => 'alice-project')
  end

  describe "#worked_on(project, count)" do
    it "creates a collaboration" do
      @albert.worked_on(@project, 2)
      new_collab = @albert.collaboration_for(@project)

      new_collab.author.should == @albert
      new_collab.project.should == @project
      new_collab.commits.should == 2
    end

    it "updates commit counts if necessary" do
      # a while ago, he'd committed a little bit
      @albert.worked_on(@project, 2)

      # but recently, he's gotten more patches accepted
      @albert.worked_on(@project, 7)
      @albert.collaboration_for(@project).commits.should == 7
    end

    it "does not create duplicates" do
      lambda do
        2.times do
          @albert.worked_on(@project, 183)
        end
      end.should change(Collaboration, :count).by(1)
    end
  end

  describe "graph-walking functions" do
    before(:each) do
      # build me up a graph, baby.
      #
      #      alice
      #        |
      #        3
      #        |
      #   rails/rails---1---carol
      #        |              |
      #        4              3
      #        |              |
      #       bob--5--carlhuda/bundler
      #
      #
      #
      #       mary---1---isolated/project---2---nathan

      @alice   = Author.gen(:github_username => 'alice')
      @bob     = Author.gen(:github_username => 'bob')
      @carol   = Author.gen(:github_username => 'carol')
      @mary    = Author.gen(:github_username => 'mary')
      @nathan  = Author.gen(:github_username => 'nathan')

      @rails_rails      = Project.gen(:name => 'rails/rails')
      @carlhuda_bundler = Project.gen(:name => 'carlhuda/bundler')
      @isolated_project = Project.gen(:name => 'isolated/project')

      @alice.worked_on  @rails_rails,      3
      @bob.worked_on    @rails_rails,      4
      @bob.worked_on    @carlhuda_bundler, 5
      @carol.worked_on  @rails_rails,      1
      @carol.worked_on  @carlhuda_bundler, 3
      @mary.worked_on   @isolated_project, 1
      @nathan.worked_on @isolated_project, 2

      Author.update_predecessor_matrix
    end

    context "#predecessor" do
      it "is nil for yourself" do
        @alice.predecessor(@alice, 1).should be_nil
      end

      it "is nil if you're trying to go between disconnected subsets" do
        @alice.predecessor(@mary, 1).should be_nil
      end

      it "finds predecessors within a subgraph" do
        @nathan.predecessor(@mary, 1).should == @mary
      end

      it "honors the weight" do
        @alice.predecessor(@carol, 1).should == @carol
        @alice.predecessor(@carol, 3).should == @bob
      end

      it "is symmetric" do
        @alice.predecessor(@carol, 2).should == @bob
        @carol.predecessor(@alice, 2).should == @bob
      end

      it "treats the weight as a minimum" do
        @alice.predecessor(@carol, 2).should == @bob
      end

      # probably need a different api for this, eh?
      it "has the right project"
    end
  end
end

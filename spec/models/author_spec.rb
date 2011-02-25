require File.expand_path('../../spec_helper', __FILE__)

describe Author do

  describe "#worked_on(project, count)" do
    before(:each) do
      @albert = described_class.gen(:github_username => 'Albert')
      @project  = Project.gen(:name => 'alice-project')
    end

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

end

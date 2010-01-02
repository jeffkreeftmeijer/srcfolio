require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Fetcher::Collaborator do
  before do
    delete_everything

    @owner =    Contributor.make(:login => 'jeffkreeftmeijer')
    @project =  Project.make(:namespace => 'jeffkreeftmeijer', :name => 'srcfolio')

    collaborator_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../../stubs/collaborators.json')).read
    @collaborators = HTTParty::Response.new(JSON(collaborator_stub_file), collaborator_stub_file, 200, 'OK')

    Fetcher::Collaborator.stub!(:get).
      with('/jeffkreeftmeijer/srcfolio/collaborators').
      and_return(@collaborators)
  end

  describe '.fetch_all' do
    it 'should call to github to get the project collaborators' do
      Fetcher::Collaborator.should_receive(:get).
        with('/jeffkreeftmeijer/srcfolio/collaborators').
        and_return(@collaborators)
      Fetcher::Collaborator.fetch_all('jeffkreeftmeijer', 'srcfolio')
    end

    it 'should link projects to collaborators' do
      Fetcher::Collaborator.fetch_all('jeffkreeftmeijer', 'srcfolio')
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions.length.should == 1
      contributor.contributions.first['member'].should == true
    end

    it 'should only link the projects once' do
      Project.delete_all
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions = [
        {
          'project' => Project.make(:namespace => 'jeffkreeftmeijer', :name => 'srcfolio').id,
          'member'   => true
        }
      ]
      contributor.save
      Fetcher::Collaborator.fetch_all('jeffkreeftmeijer', 'srcfolio')
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions.length.should == 1
    end

    it 'should create invisible contributors if they do not exist yet' do
      Fetcher::Collaborator.fetch_all('jeffkreeftmeijer', 'srcfolio')
      contributor = Contributor.find_by_login('bob')
      contributor.should_not be_nil
      contributor.visible.should == false
    end
    
    it 'should make team memberships invisible by default' do
      Fetcher::Collaborator.fetch_all('jeffkreeftmeijer', 'srcfolio')
      contributor = Contributor.find_by_login('bob')
      contributor.contributions.first['visible'].should == false
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Fetcher::Repository do
  before do
    delete_everything

    repositories_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../../stubs/repositories.json')).read
    @repositories = HTTParty::Response.new(JSON(repositories_stub_file), repositories_stub_file, 200, 'OK')
    Fetcher::Repository.stub!(:get).with('/jeffkreeftmeijer').and_return(@repositories)
    Contributor.create(:login => 'jeffkreeftmeijer')
  end

  describe '.fetch_all' do
    it 'should call to github to get the user repositories' do
      Fetcher::Repository.should_receive(:get).
        with('/jeffkreeftmeijer').
        and_return(@repositories)
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')
    end

    it 'should create new projects' do
      Project.delete_all
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')

      projects = Project.all
      projects.count.should eql 3
      project = Project.first
      project.name.should ==         'srcfolio'
      project.github_url.should ==   'http://github.com/jeffkreeftmeijer/srcfolio'
      project.description.should ==  'src{folio}'
      project.homepage.should ==     'http://srcfolio.com'
      project.fork.should ==         false
      project.namespace.should ==    'jeffkreeftmeijer'
      project.owner.should be_instance_of(Contributor)
    end

    it 'should add the projects to the owners ownerships' do
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions.length.should == 3
      contributor.contributions.first['owner'].should == true
    end

    it 'should only link the projects once' do
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions = [
        {
          'project' => Project.make(:namespace => 'jeffkreeftmeijer', :name => 'srcfolio').id,
          'owner'   => true
        }
      ]
      contributor.save
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions.length.should == 3
    end

    it 'should create links to the projects homepages and github repos' do
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')
      project = Project.first
      links = project.links
      project.links.should_not be_empty
      links[0].should be_instance_of Link
      links[0].name.should == 'Project Homepage'
      links[0].url.should ==  'http://srcfolio.com'
      links[1].should be_instance_of Link
      links[1].name.should == 'Source Code'
      links[1].url.should ==  'http://github.com/jeffkreeftmeijer/srcfolio'
    end

    it 'should create the links only once' do
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')
      project = Project.first
      links = project.links
      project.links.length.should eql 2
    end

    it 'should create new jobs to fetch the project teams and network data' do
      Delayed::Job.delete_all
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')
      jobs = Delayed::Job.all
      jobs.length.should == 6
      jobs[0].handler.should include('Fetcher::Collaborator', ':fetch_all', 'jeffkreeftmeijer', 'srcfolio')
      jobs[1].handler.should include('Fetcher::Network', ':fetch_all', 'jeffkreeftmeijer', 'srcfolio')
    end
  end
end

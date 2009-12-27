require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Fetcher::User do
  before do
    delete_everything

    user_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../stubs/user.json')).read
    @user = HTTParty::Response.new(JSON(user_stub_file), user_stub_file, 200, 'OK')
    Fetcher::User.stub!(:get).with('/jeffkreeftmeijer').and_return(@user)
    Fetcher::User.stub!(:get).with('/idontexist').and_return(HTTParty::Response.new('', '', 404, 'Not Found'))
  end

  describe '.find' do
    it 'should call to github to get the user' do
      Fetcher::User.should_receive(:get).
        with('/jeffkreeftmeijer').
        and_return(@user)
      Fetcher::User.fetch('jeffkreeftmeijer')
    end

    it 'should create a new contributor' do
      Fetcher::User.fetch('jeffkreeftmeijer')
      contributor = Contributor.last(:order => 'created_at')
      contributor.login.should ==     'jeffkreeftmeijer'
      contributor.name.should ==      'Jeff Kreeftmeijer'
      contributor.company.should ==   '80beans'
      contributor.location.should ==  'The Netherlands'
      contributor.website.should ==   'http://jeffkreeftmeijer.nl'
      contributor.email.should ==     'jeff@kreeftmeijer.nl'
    end

    it 'should raise an error when the specified user could not be found' do
      begin
      Fetcher::User.fetch('idontexist').should raise_error(NotFound, 'No Github user was found named "idontexist"')
      rescue; end
    end
  end
end

describe Fetcher::Repository do
  before do
    delete_everything

    repositories_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../stubs/repositories.json')).read
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
      Fetcher::Repository.fetch_all('jeffkreeftmeijer')

      projects = Project.all
      projects.count.should eql 3
      projects.first.name.should ==         'srcfolio'
      projects.first.github_url.should ==   'http://github.com/jeffkreeftmeijer/srcfolio'
      projects.first.description.should ==  'src{folio}'
      projects.first.homepage.should ==     'http://srcfolio.com'
      projects.first.fork.should ==         false
      projects.first.namespace.should ==    'jeffkreeftmeijer'
      projects.first.owner.should be_instance_of(Contributor)
    end
  end
end

describe Fetcher::Network do
  before do
    delete_everything

    @owner =    Contributor.make(:login => 'jeffkreeftmeijer')
    @project =  Project.make(:namespace => 'jeffkreeftmeijer', :name => 'srcfolio')

    network_meta_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../stubs/network_meta.json')).read
    @network_meta = HTTParty::Response.new(JSON(network_meta_stub_file), network_meta_stub_file, 200, 'OK')

    network_data_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../stubs/network_data.json')).read
    @network_data = HTTParty::Response.new(JSON(network_data_stub_file), network_data_stub_file, 200, 'OK')

    Fetcher::Network.stub!(:get).
      with('/jeffkreeftmeijer/srcfolio/network_meta').
      and_return(@network_meta)
    
    Fetcher::Network.stub!(:get).
      with('/jeffkreeftmeijer/srcfolio/network_data_chunk', :query => {:nethash => '0a54d8ce980e06006bd7fd00b4319c944622b5d8'}).
      and_return(@network_data)
  end

  describe '.fetch_all' do
    it 'should call to github to get the network meta data' do
      Fetcher::Network.should_receive(:get).
        with('/jeffkreeftmeijer/srcfolio/network_meta').
        and_return(@network_meta)

      Fetcher::Network.should_receive(:get).
        with('/jeffkreeftmeijer/srcfolio/network_data_chunk', :query => {:nethash => '0a54d8ce980e06006bd7fd00b4319c944622b5d8'}).
        and_return(@network_data)

      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
    end
  end
  
  it 'should link contributors to projects' do
    Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
    contributor = Contributor.find_by_login('jeffkreeftmeijer')
    contributor.contributions.should_not be_empty 
    project = Project.find contributor.contributions.first['project']
    project.should be_instance_of Project
    project.name.should == 'srcfolio'
  end

  it 'should create contributors if they do not exist yet' do
    Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
    Contributor.find_by_login('bob').should_not be_nil
  end

  it 'should only index contributors that have committed to space 1' do
    Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
    Contributor.find_by_login('charlie').should be_nil
  end
  
  it 'should set the commit count for the project' do
    Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
    Project.find_by_namespace_and_name('jeffkreeftmeijer', 'srcfolio').commits.should == 23
  end
end

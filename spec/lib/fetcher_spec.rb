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

    it 'should update an existing user' do
      Contributor.delete_all
      Contributor.make(:login => 'jeffkreeftmeijer')
      Fetcher::User.fetch('jeffkreeftmeijer')
      contributors = Contributor.find_all_by_login('jeffkreeftmeijer')
      contributors.length.should == 1
      contributors.first.name.should == 'Jeff Kreeftmeijer'
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
      projects.first.visible.should ==      true
      projects.first.namespace.should ==    'jeffkreeftmeijer'
      projects.first.owner.should be_instance_of(Contributor)
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

    it 'should make forks invisible' do
     Fetcher::Repository.fetch_all('jeffkreeftmeijer')
     project = Project.find_by_namespace_and_name('jeffkreeftmeijer', 'gemcutter')
     project.visible?.should == false
    end
  end
end

describe Fetcher::Collaborator do
  before do
    delete_everything

    @owner =    Contributor.make(:login => 'jeffkreeftmeijer')
    @project =  Project.make(:namespace => 'jeffkreeftmeijer', :name => 'srcfolio')

    collaborator_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../stubs/collaborators.json')).read
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

    it 'should create contributors if they do not exist yet' do
      Fetcher::Collaborator.fetch_all('jeffkreeftmeijer', 'srcfolio')
      Contributor.find_by_login('bob').should_not be_nil
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

    it 'should link contributors to each project once and set the commit count and commit dates' do
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions.should_not be_empty
      contributor.contributions.length.should == 1
      project = Project.find contributor.contributions.first['project']
      project.should be_instance_of Project
      project.name.should == 'srcfolio'
      contributor.contributions.first['commits'].should == 21
      contributor.contributions.first['started_at'].should == '2009-12-13 08:03:03'.to_time
      contributor.contributions.first['stopped_at'].should == '2009-12-21 02:12:06'.to_time
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
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions.length.should == 1
      contributor.contributions.first['member'].should == true
    end

    it 'should create contributors if they do not exist yet' do
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      Contributor.find_by_login('bob').should_not be_nil
    end

    it 'should only index contributors that have committed to space 1' do
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      Contributor.find_by_login('charlie').should be_nil
    end
        
    it 'should set the commit count for the project and merge contributors without a login but matching names' do
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      Project.find_by_namespace_and_name('jeffkreeftmeijer', 'srcfolio').commits.should == 23
    end
  end
end

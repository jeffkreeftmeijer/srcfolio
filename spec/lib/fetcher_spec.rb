require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Fetcher::User do
  before do
    Contributor.delete_all

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

    it 'should go fetch the contributor repositories when done fetching the contributor' do
      Fetcher::Repository.should_receive(:fetch_all_by_owner_login).with('jeffkreeftmeijer')
      Fetcher::User.fetch('jeffkreeftmeijer')
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
    Project.delete_all
    repositories_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../stubs/repositories.json')).read
    @repositories = HTTParty::Response.new(JSON(repositories_stub_file), repositories_stub_file, 200, 'OK')
    Fetcher::Repository.stub!(:get).with('/jeffkreeftmeijer').and_return(@repositories)
    Contributor.create(:login => 'jeffkreeftmeijer')
  end

  describe '.fetch_all_by_user_login' do
    it 'should call to github to get the user repositories' do
      Fetcher::Repository.should_receive(:get).
        with('/jeffkreeftmeijer').
        and_return(@repositories)
      Fetcher::Repository.fetch_all_by_owner_login('jeffkreeftmeijer')
    end

    it 'should create new projects' do
      Fetcher::Repository.fetch_all_by_owner_login('jeffkreeftmeijer')
      projects = Project.all
      projects.count.should eql 3
      projects.first.name.should ==  'wakoopa'
      projects.first.owner.should be_instance_of(Contributor)
    end
  end
end

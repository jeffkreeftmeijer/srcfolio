require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Fetcher::User do
  before do
    delete_everything

    user_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../../stubs/user.json')).read
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

    it 'should update an existing user and make it visible' do
      Contributor.delete_all
      Contributor.make(:login => 'jeffkreeftmeijer', :visible => false)
      Fetcher::User.fetch('jeffkreeftmeijer')
      contributors = Contributor.find_all_by_login('jeffkreeftmeijer')
      contributors.length.should == 1
      contributors.first.name.should == 'Jeff Kreeftmeijer'
      contributors.first.visible.should == true
    end

    it 'should create a new job to fetch projects' do
      Navvy::Job.delete_all
      Fetcher::User.fetch('jeffkreeftmeijer')
      job = Navvy::Job.last(:order => 'created_at')
      job.should_not be_nil
      job.object.should == 'Fetcher::Repository'
      job.method_name.should == :fetch_all
      job.args.should == ['jeffkreeftmeijer']
    end

    it 'should raise an error when the specified user could not be found' do
      begin
      Fetcher::User.fetch('idontexist').should raise_error(NotFound, 'No Github user was found named "idontexist"')
      rescue; end
    end
  end
end

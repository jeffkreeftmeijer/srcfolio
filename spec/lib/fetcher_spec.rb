require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Fetcher::User do
  before do
    @user_jeffkreeftmeijer = JSON open(File.expand_path(File.dirname(__FILE__) + '/../stubs/user_jeffkreeftmeijer.json'))
  end

  describe '.find' do
    it 'should call to github to get the user' do
      Fetcher::User.should_receive(:get).
        with('/jeffkreeftmeijer').
        and_return(@user_jeffkreeftmeijer)
      Fetcher::User.fetch('jeffkreeftmeijer')
    end

    it 'should create a new contributor' do
      Fetcher::User.fetch('jeffkreeftmeijer')
      Contributor.find_by_login('jeffkreeftmeijer').should_not be_nil
    end
  end
end

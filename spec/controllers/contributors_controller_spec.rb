require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContributorsController do
  before do
    @contributor = Contributor.make(:login => 'charl1e', :name => 'Charlie')
  end

  it 'should show a contributor page' do
    get 'show', :id => @contributor.login
    response.should be_success
    response.should render_template('contributors/show')
    assigns[:contributor].should_not be_nil
    assigns[:contributor].name.should eql('Charlie')
  end
end
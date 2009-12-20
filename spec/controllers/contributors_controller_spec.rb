require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContributorsController do
  before do
    @contributor = Contributor.make(
      :login => 'charl1e',
      :name => 'Charlie'
    )
    
    @contributor_with_contributions = Contributor.make(
      :login => 'dav3',
      :name => 'Dave',
      :contributions => [
        Project.new(:name => 'Project1')
      ]
    )
  end

  it 'should show a contributor page' do
    get 'show', :id => @contributor.login
    response.should be_success
    response.should render_template('contributors/show')
    assigns[:contributor].should_not be_nil
    assigns[:contributor].name.should eql('Charlie')
  end
  
  it 'should render a 404 page when the user could not be found' do
    get 'show', :id => 'z0e'
    response.status.should == '404 Not Found'
    response.should_not be_success
    response.should render_template('contributors/not_found')
  end
  
  it 'should show a contributor page with contributions' do
    get 'show', :id => @contributor_with_contributions.login
    assigns[:contributions].count.should eql 1
    assigns[:contributions].each {|c| c.should be_instance_of Project }
  end
end

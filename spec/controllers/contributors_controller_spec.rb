require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ContributorsController do
  before do
    delete_everything

    project = Project.make(:name => 'Project1')
    project.save

    @contributor = Contributor.make(
      :login => 'charl1e',
      :name => 'Charlie'
    )

    @contributor_with_contributions = Contributor.make(
      :login => 'dav3',
      :name => 'Dave',
      :contributions => [
        {
          :project => project.id,
          :visible => true
        }
      ]
    )
  end

  it 'should show a list of contributors' do
    get 'index'
    response.should be_success
    response.should render_template('contributors/index')
    assigns[:contributors].should_not be_nil
    assigns[:contributors].count == 2
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
    job = Navvy::Job.last(:order => 'created_at')
    job.should_not be_nil
    job.object.should == 'Fetcher::User'
    job.method_name.should == :fetch
    job.args.should == ['z0e']
  end

  it 'should show a contributor page with contributions' do
    get 'show', :id => @contributor_with_contributions.login
    assigns[:contributions].count.should == 1
    assigns[:contributions].each do |c|
       c['project'].should be_instance_of Project
       c['visible'].should eql true
     end
  end
end

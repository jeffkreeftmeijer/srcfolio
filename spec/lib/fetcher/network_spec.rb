require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Fetcher::Network do
  before do
    delete_everything

    @owner =    Contributor.make(:login => 'jeffkreeftmeijer')
    @project =  Project.make(:namespace => 'jeffkreeftmeijer', :name => 'srcfolio')

    network_meta_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../../stubs/network_meta.json')).read
    @network_meta = HTTParty::Response.new(JSON(network_meta_stub_file), network_meta_stub_file, 200, 'OK')

    network_data_stub_file = open(File.expand_path(File.dirname(__FILE__) + '/../../stubs/network_data.json')).read
    @network_data = HTTParty::Response.new(JSON(network_data_stub_file), network_data_stub_file, 200, 'OK')

    Fetcher::Network.stub!(:get).
      with('/jeffkreeftmeijer/srcfolio/network_meta').
      and_return(@network_meta)

    Fetcher::Network.stub!(:get).
      with(
        '/jeffkreeftmeijer/srcfolio/network_data_chunk',
        :query => {
          :nethash => '0a54d8ce980e06006bd7fd00b4319c944622b5d8',
          :start => 0,
          :end => 22
        }
      ).
      and_return(@network_data)
  end

  describe '.fetch_all' do
    it 'should call to github to get the network meta data' do
      Fetcher::Network.should_receive(:get).
        with('/jeffkreeftmeijer/srcfolio/network_meta').
        and_return(@network_meta)

      Fetcher::Network.should_receive(:get).
        with(
          '/jeffkreeftmeijer/srcfolio/network_data_chunk',
          :query => {
            :nethash => '0a54d8ce980e06006bd7fd00b4319c944622b5d8',
            :start => 0,
            :end => 22
          }
        ).
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
      contributor.contributions.first['commits'].should == 3
      contributor.contributions.first['started_at'].should == '2009-01-01 00:00:00'.to_time
      contributor.contributions.first['stopped_at'].should == '2009-01-03 00:00:00'.to_time
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

    it 'should create invisible contributors if they do not exist yet' do
      Contributor.delete_all
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      contributor = Contributor.find_by_login('b0b')
      contributor.should_not be_nil
      contributor.visible.should == false
    end

    it 'should only index contributors that have committed to space 1' do
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      Contributor.find_by_login('charlie').should be_nil
    end

    it 'should set the commit count for the project' do
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      Project.find_by_namespace_and_name('jeffkreeftmeijer', 'srcfolio').commits.should == 4
    end

    it 'should make forks invisible by default' do
      project = Project.find_by_namespace_and_name('jeffkreeftmeijer', 'srcfolio')
      project.fork = true
      project.save
      Fetcher::Network.fetch_all('jeffkreeftmeijer', 'srcfolio')
      contributor = Contributor.find_by_login('jeffkreeftmeijer')
      contributor.contributions.first['visible'].should == false
    end
  end
end

require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe Contributor do
  describe '#merge' do
    before do
      delete_everything

      @contributor = Contributor.make(
        :login => '',
        :contributions => [
          {
            'project'     => 123,
            'owner'       => true,
            'commits'     => 3
          },
          {
            'project'     => 321,
            'commits'     => 12,
            'started_at'  => 'January 1 2008',
            'stopped_at'  => 'January 1 2010'
          }
        ]
      )
    end
    
    describe 'with an existing contributor' do
      before do
        Contributor.make(
          :name => 'Alice',
          :login => 'al1ce',
          :contributions => [
            {
              'project' => 321,
              'owner'   => true
            }
          ]
        )

        @contributor.merge 'al1ce'
        @merged_contributor = Contributor.find_by_login('al1ce')
      end

      it 'should delete the contributor' do
        Contributor.find(@contributor.id).should be_nil
      end

      it 'should add the contributions to the leading contributor' do      
        @merged_contributor.contributions.length.should == 2
      end

      it 'should merge existing contributions' do
        contribution = @merged_contributor.contributions.last
        contribution['commits'].should_not be_nil
        contribution['started_at'].should_not be_nil
        contribution['stopped_at'].should_not be_nil
      end
    end
    
    describe 'with a contributor that does not exist yet' do
      before do
        @contributor.merge 'al1ce'
      end
      it 'should not delete the contributor' do
        contributor = Contributor.find(@contributor.id)
        contributor.should_not be_nil
        contributor.should be_instance_of Contributor
      end
      
      it 'should add the login' do
        contributor = Contributor.find(@contributor.id)
        contributor.login.should == 'al1ce'
      end
    end
  end
end

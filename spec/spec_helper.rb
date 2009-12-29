ENV["RAILS_ENV"] ||= 'test'
require File.expand_path(File.join(File.dirname(__FILE__),'..','config','environment'))
require 'spec/autorun'
require 'spec/rails'

Dir[File.expand_path(File.join(File.dirname(__FILE__),'support','**','*.rb'))].each {|f| require f}

Spec::Runner.configure do |config|
end

require File.expand_path(File.join(File.dirname(__FILE__), 'blueprints'))

def delete_everything
  Project.delete_all
  Contributor.delete_all
  Delayed::Job.delete_all
end
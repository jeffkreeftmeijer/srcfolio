require 'rubygems'
require 'httparty'

require 'fetcher/user'
require 'fetcher/repository'
require 'fetcher/collaborator'

module Fetcher
  class NotFound < StandardError; end
end

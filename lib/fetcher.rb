require 'rubygems'
require 'httparty'

module Fetcher
  class User
    include HTTParty
    base_uri 'http://github.com/api/v2/json/user/show/'

    class << self
      def fetch(github_username)
        response = get("/#{github_username}")
        Contributor.create(:login => response['user']['login'])
      end
    end
  end
end

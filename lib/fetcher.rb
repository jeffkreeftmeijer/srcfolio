require 'rubygems'
require 'httparty'

module Fetcher

  class NotFound < StandardError; end

  class User
    include HTTParty
    base_uri 'http://github.com/api/v2/json/user/show/'

    class << self
      def fetch(github_username)
        response = get("/#{github_username}")
        raise(NotFound, "No Github user was found named \"#{github_username}\"") if response.code == 404

        contributor = Contributor.create(
          :login =>     response['user']['login'],
          :name =>      response['user']['name'],
          :company =>   response['user']['company'],
          :location =>  response['user']['location'],
          :website =>   response['user']['blog'],
          :email =>     response['user']['email']
        )

        Fetcher::Repository.fetch_all(contributor.login)
      end
    end
  end

  class Repository
    include HTTParty
    base_uri 'http://github.com/api/v2/json/repos/show/'

    class << self
      def fetch_all(github_username)
        response = get("/#{github_username}")
        response['repositories'].each do |repository|
          Project.create(
            :name =>        repository['name'],
            :namespace =>   repository['owner'],
            :github_url =>  repository['url'],
            :description => repository['description'],
            :homepage =>    repository['homepage'],
            :fork =>        repository['fork'],
            :owner =>       Contributor.find_by_login(github_username)
          )
        end
      end
    end
  end

  class Network
    include HTTParty
    base_uri 'http://github.com/'

    class << self
      def fetch_all(project_namespace, project_name)
        network_meta = get("/#{project_namespace}/#{project_name}/network_meta")
        get("/#{project_namespace}/#{project_name}/network_data", :query => {:nethash => network_meta['nethash']})
        Contributor.find_by_login('jeffkreeftmeijer').contributions << Project.find_by_namespace_and_name(project_namespace, project_name)
      end
    end
  end
end

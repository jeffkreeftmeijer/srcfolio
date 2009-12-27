require 'rubygems'
require 'httparty'

module Fetcher

  class NotFound < StandardError; end

  class User
    include HTTParty
    base_uri 'http://github.com/api/v2/json/user/show/'
    format :json

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
      end
    end
  end

  class Repository
    include HTTParty
    base_uri 'http://github.com/api/v2/json/repos/show/'
    format :json

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
    format :json

    class << self
      def fetch_all(project_namespace, project_name)
        network_meta = get("/#{project_namespace}/#{project_name}/network_meta")
        network_data = get("/#{project_namespace}/#{project_name}/network_data_chunk", :query => {:nethash => network_meta['nethash']})
        project = Project.find_by_namespace_and_name(project_namespace, project_name)
        project.commits = network_data['commits'].length
        project.save
        network_data['commits'].each do |commit|
          if commit['login'] && commit['space'] == 1
            contributor = Contributor.find_or_create_by_login(commit['login'])
            contributor.contributions << {'project' => project.id}
            contributor.save
          end
        end
      end
    end
  end
end

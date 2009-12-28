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
        
        contributor = Contributor.find_or_create_by_login(response['user']['login'])
        contributor.update_attributes!(
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
        contributor = Contributor.find_by_login(github_username)
        response['repositories'].each do |repository|
          project = Project.create(
            :name =>        repository['name'],
            :namespace =>   repository['owner'],
            :github_url =>  repository['url'],
            :description => repository['description'],
            :homepage =>    repository['homepage'],
            :fork =>        repository['fork'],
            :visible =>     repository['fork']? false : true,
            :owner =>       Contributor.find_by_login(github_username)
          )  
          contributor.contributions << {
            'project' =>  project.id,
            'member' =>   true
          }
        end
        contributor.save 
      end
    end
  end
  
  class Collaborator
    include HTTParty
    base_uri 'http://github.com/api/v2/json/repos/show/'
    format :json
    
    class << self
      def fetch_all(project_namespace, project_name)
        collaborators = get("/#{project_namespace}/#{project_name}/collaborators")
        project = Project.find_by_namespace_and_name(project_namespace, project_name)
        collaborators['collaborators'].each do |collaborator|
          contributor = Contributor.find_or_create_by_login(collaborator)
          contributor.contributions << {
            'project' =>  project.id,
            'member' =>   true
          }
          contributor.save
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

        contributions = {}

        network_data['commits'].each do |commit|
          if commit['login'] && commit['space'] == 1

            contribution = {
              :login =>       commit['login'],
              :commits =>     contributions[commit['login']] ? contributions[commit['login']][:commits] += 1 : 1
            }

            contribution[:started_at] = contributions[commit['login']].nil? || contributions[commit['login']][:started_at].nil? || commit['date'].to_time < contributions[commit['login']][:started_at].to_time ?
              commit['date'].to_time :
              contributions[commit['login']][:started_at]

            contribution[:stopped_at] = contributions[commit['login']].nil? || contributions[commit['login']][:stopped_at].nil? || commit['date'].to_time > contributions[commit['login']][:stopped_at].to_time ?
              commit['date'].to_time :
              contributions[commit['login']][:stopped_at]

            contributions.merge!({commit['login'] => contribution})
          end
        end

        contributions.values.each do |contribution|
          contributor = Contributor.find_or_create_by_login(contribution[:login])
          contributor.contributions << {
            'project' =>    project.id,
            'commits' =>    contribution[:commits],
            'started_at' => contribution[:started_at],
            'stopped_at' => contribution[:stopped_at]
          }
          contributor.save
        end
      end
    end
  end
end

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
          :email =>     response['user']['email'],
          :visible =>   true
        )

        Fetcher::Repository.send_later(:fetch_all, github_username)
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

          project = Project.find_or_create_by_namespace_and_name(
            repository['owner'],
            repository['name']
          )

          if project.links.select{|l| l.name == 'Project Homepage'}.empty? && !repository['homepage'].empty?
            project.links << Link.new('name' => 'Project Homepage', 'url' => repository['homepage'])
          end

          if project.links.select{|l| l.name == 'Source Code'}.empty?
            project.links << Link.new('name' => 'Source Code', 'url' => repository['url'])
          end

          project.update_attributes!(
            :github_url =>  repository['url'],
            :description => repository['description'],
            :homepage =>    repository['homepage'],
            :fork =>        repository['fork'],
            :owner =>       Contributor.find_by_login(github_username)
          )

          existing_contribution = contributor.contributions.select{|c| c['project'] == project.id}.first
          contributor.contributions.delete(existing_contribution)

          contributor.contributions << (existing_contribution || {}).merge({
            'project' =>  project.id,
            'owner' =>    true,
            'visible' =>  !project.fork?
          })

          Fetcher::Collaborator.send_later(:fetch_all, github_username, repository['name'])
          Fetcher::Network.send_later(:fetch_all, github_username, repository['name'])
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
          unless contributor = Contributor.find_by_login(collaborator)
            contributor = Contributor.create(:login => collaborator, :visible => false)
          end

          existing_contribution = contributor.contributions.select{|c| c['project'] == project.id}.first
          contributor.contributions.delete(existing_contribution)

          contributor.contributions << (existing_contribution || {}).merge({
            'project' =>  project.id,
            'member' =>   true,
            'visible' =>  existing_contribution ? existing_contribution['visible'] || false : false
          })

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
        network_data = get(
          "/#{project_namespace}/#{project_name}/network_data_chunk",
          :query => {
            :nethash => network_meta['nethash'],
            :start => 0,
            :end => network_meta['dates'].count - 1
          }
        )
        project = Project.find_by_namespace_and_name(project_namespace, project_name)
        project.commits = network_data['commits'].length
        project.save

        contributions = {}

        network_data['commits'].each do |commit|
          if commit['space'] == 1
            if commit['login'].empty?
              contributor = network_data['commits'].select{|c| c['author'] == commit['author'] && !c['login'].empty?}.first
              commit['login'] = contributor ? contributor['login'] : ''
            end

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
          unless contributor = Contributor.find_by_login(contribution[:login])
            contributor = Contributor.create(:login => contribution[:login], :visible => false)
          end

          existing_contribution = contributor.contributions.select{|c| c['project'] == project.id}.first
          contributor.contributions.delete(existing_contribution)

          contributor.contributions << (existing_contribution || {}).merge({
            'project' =>    project.id,
            'commits' =>    contribution[:commits],
            'started_at' => contribution[:started_at],
            'stopped_at' => contribution[:stopped_at],
            'visible' =>    !project.fork?
          })
          contributor.save
        end
      end
    end
  end
end

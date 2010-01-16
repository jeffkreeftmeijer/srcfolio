module Fetcher
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
          
          Navvy::Job.enqueue(Fetcher::Collaborator, :fetch_all, github_username, repository['name'])
          Navvy::Job.enqueue(Fetcher::Network, :fetch_all, github_username, repository['name'])
        end
        contributor.save
      end
    end
  end
end

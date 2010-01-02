module Fetcher
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
end

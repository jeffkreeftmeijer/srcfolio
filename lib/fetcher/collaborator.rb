module Fetcher
  class Collaborator
    include HTTParty
    base_uri 'http://github.com/api/v2/json/repos/show/'
    format :json

    class << self
      
      def fetch_all(project_namespace, project_name)
        add_projects_to_contributors(
          Project.find_by_namespace_and_name(project_namespace, project_name).id,
          get("/#{project_namespace}/#{project_name}/collaborators")['collaborators']
        )
      end
      
      def add_projects_to_contributors(project, collaborators)
        collaborators.each do |collaborator|
          contributor =   Contributor.find_or_create_invisible_by_login(collaborator)
          contribution =  find_existing_contribution(project, contributor)

          contributor.contributions << contribution.merge({
            'project' =>  project,
            'member' =>   true,
            'visible' =>  contribution['visible'] || false
          })

          contributor.save
        end
      end
      
      def find_existing_contribution(id, contributor)
        contributor.contributions.delete(contributor.contributions.
          select{|contribution| contribution['project'] == id}.first) || {}
      end
    end
  end
end

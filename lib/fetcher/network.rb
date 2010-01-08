module Fetcher
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

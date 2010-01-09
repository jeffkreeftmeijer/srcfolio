class Contributor
  include MongoMapper::Document

  key :login,         String
  key :name,          String
  key :description,   String
  key :company,       String
  key :location,      String
  key :website,       String
  key :email,         String
  key :contributions, Array
  key :visible,       Boolean, :default => true
  timestamps!

  def best_name
    (name.nil? || name.empty?) ? login : name
  end

  def gravatar_url(size = nil)
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email || '')}.jpg?s=#{size||80}"
  end

  def visible_contributions
    contributions.select{|contribution| contribution['visible']}
  end

  def visible_contributions_with_projects
    visible_contributions_with_projects = visible_contributions.map do |contribution|
      contribution.merge({'project' => Project.find(contribution['project'])})
    end

    visible_contributions_with_projects.sort_by do |contribution|
      [contribution['order'] || 0, - (contribution['stopped_at'] || 0).to_i]
    end
  end

  def merge(login)
    if contributor = Contributor.find_by_login(login)
      contributions.each do |contribution|
        if existing_contribution = contributor.contributions.select{|c| c['project'] == contribution['project']}.first
          contributor.contributions.delete(existing_contribution)
        end
        
        contributor.contributions <<
          (existing_contribution || {}).merge({
            'commits' =>    (existing_contribution ? existing_contribution['commits'] : 0) + (contribution['commits'] || 0),
            'started_at' => contribution['started_at'],
            'stopped_at' => contribution['stopped_at']
          })

        contributor.save
      end
      destroy
    else
      update_attributes(:login => login)
    end
  end

  class << self
    def find_or_create_invisible_by_login(login)
      find_by_login(login) || create(:login => login, :visible => false)
    end
  end

end

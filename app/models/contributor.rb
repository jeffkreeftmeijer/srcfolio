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

  def  gravatar_url
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email || '')}.jpg"
  end

  def visible_contributions_with_projects
    contributions_with_projects = contributions.map do |c|
      c.merge({
        'project' => Project.find(c['project'])
      })
    end
    
    visible_contributions_with_projects = contributions_with_projects.select do |c|
      c['project'].visible?
    end
    
    visible_contributions_with_projects.sort_by do |c|
      c['stopped_at'] ? c['stopped_at'].to_i : 0
    end.reverse!
  end
end

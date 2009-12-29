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
  timestamps!

  def best_name
    name || login
  end
  
  def  gravatar_url
    "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email || '')}.jpg"
  end
end

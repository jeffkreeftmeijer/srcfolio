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
  key :memberships,   Array
  key :ownerships,    Array
  timestamps!
  
  def best_name
    name || login
  end              
end

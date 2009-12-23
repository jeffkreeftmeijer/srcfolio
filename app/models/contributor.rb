class Contributor
  include MongoMapper::Document

  key :login,         String
  key :name,          String
  key :namespace,     String
  key :company,       String
  key :location,      String
  key :website,       String
  key :email,         String
  key :contributions, Array
  timestamps!               
  
  #many :contributions, :class => Project
end

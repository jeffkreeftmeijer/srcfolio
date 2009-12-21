class Contributor
  include MongoMapper::Document

  key :login,     String
  key :name,      String
  key :namespace, String
  key :company,   String
  key :location,  String
  key :website,   String
  key :email,     String
  timestamps!
  
  many :contributions, :class => Project
end

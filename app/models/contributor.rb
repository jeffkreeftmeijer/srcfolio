class Contributor
  include MongoMapper::Document

  key :login, String
  key :name, String
end
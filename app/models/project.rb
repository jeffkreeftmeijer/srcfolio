class Project
  include MongoMapper::Document

  key :name,  String
  key :owner, Contributor
end
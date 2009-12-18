require 'machinist/mongomapper'
require 'sham'

Contributor.blueprint do
  login 'bob'
  name  'Bob'
end

Project.blueprint do
  name 'project'
end
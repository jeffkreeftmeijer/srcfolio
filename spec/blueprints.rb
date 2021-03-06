require 'machinist/mongomapper'
require 'sham'

Contributor.blueprint do
  login 'b0b'
  name  'Bob'
  email name ? "#{name.downcase}@example.com" : ''
end

Project.blueprint do
  name        'project'
  description 'A really cool project'
  owner       Contributor.make
  commits     100
end
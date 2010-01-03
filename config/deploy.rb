set :application, "srcfolio"
 
role :app, "srcfolio.com"
role :web, "srcfolio.com"
role :db,  "srcfolio.com", :primary => true

set :scm, :git
set :repository,  "git://github.com/jeffkreeftmeijer/srcfolio.git"
set :deploy_to,   "~/app"
set :use_sudo,    false
 
set :group, "srcfolio"
set :user,  "srcfolio"
set :application, "srcfolio"
 
role :app, "srcfolio.com"
role :web, "srcfolio.com"
role :db,  "srcfolio.com", :primary => true

set :scm, :git
set :repository,  "git://github.com/jeffkreeftmeijer/srcfolio.git"
set :use_sudo,    false
 
set :group, "srcfolio"
set :user,  "srcfolio"

namespace :deploy do
  desc "Restarting mod_rails with restart.txt"
  task :restart, :roles => :app do
    run "touch #{current_path}/tmp/restart.txt"
  end
 
  desc "Run gem bundle"
  task :bundle, :roles => :app do
    run "cd #{release_path} && gem bundle --cached"
  end
end

after "deploy:update_code", "deploy:bundle"

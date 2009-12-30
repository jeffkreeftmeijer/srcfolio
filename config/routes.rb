ActionController::Routing::Routes.draw do |map|
  map.resources :contributors, :only => [:index, :show]
  map.root      :controller => :contributors
  
  map.namespace :admin do |admin|
    admin.resources :contributors, :only => :index
    admin.resources :jobs, :only => :index
  end
end

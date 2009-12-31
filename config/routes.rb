ActionController::Routing::Routes.draw do |map|
  map.contributor_with_subdomain '', :controller => 'contributors', :action => 'show',  :conditions => { :subdomain => /.+/ }
  
  map.resources :contributors, :only => [:index, :show], :conditions => { :subdomain => false }
  map.root      :controller => :contributors
  
  map.namespace :admin, :conditions => { :subdomain => false } do |admin|
    admin.root :controller => :jobs
    admin.resources :contributors, :only => :index
    admin.resources :jobs, :only => :index
  end
end

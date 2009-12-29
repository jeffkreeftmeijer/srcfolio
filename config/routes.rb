ActionController::Routing::Routes.draw do |map|
  map.resources :contributors, :only => [:index, :show]
  map.root      :controller => :contributors
end

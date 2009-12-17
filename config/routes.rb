ActionController::Routing::Routes.draw do |map|
  map.resources :contributors, :only => :show
end

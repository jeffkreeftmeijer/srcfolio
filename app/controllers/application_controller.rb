class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  
  protected

  def authenticate
    authenticate_or_request_with_http_basic do |username, password|
      config = YAML.load_file("#{RAILS_ROOT}/config/config.yml")
      username == config['admin']['login'] && password == config['admin']['password'] || RAILS_ENV == 'development'
    end
  end
end

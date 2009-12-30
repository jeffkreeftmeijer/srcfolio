class Admin::ContributorsController < ApplicationController
  layout 'admin'
  def index
    @contributors = Contributor.all(:visible => false, :login => {'$ne' => ''}, :order => 'login')
  end
end

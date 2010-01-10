class Admin::ContributorsController < ApplicationController
  before_filter :authenticate
  
  layout 'admin'
  def index
    @invisible_contributors = Contributor.all(
      :visible => false,
      :login => {'$ne' => ''},
      :order => 'login'
    )
    @broken_contributors =  Contributor.all(
      :login => '',
      :contributions => {'$ne' => nil}
    ).sort_by{|c| c.contributions.length}.reverse!
  end
  
  def update
    @contributor = Contributor.find(params[:id])
    if existing_contributor = Contributor.find_by_login(params[:contributor][:login])
      raise existing_contributor
    else
      @contributor = Contributor.find(params[:id])
      @contributor.update_attributes(params[:contributor])
      Fetcher::User.send_later(:fetch, params[:login])
    end
    redirect_to admin_contributors_path
  end
end

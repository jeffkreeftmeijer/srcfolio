class ContributorsController < ApplicationController
  def index
    @contributors = Contributor.all(:login => {'$ne' => ''}, :visible => true).sort_by{|c| c.best_name.downcase }
  end

  def show
    unless @contributor = Contributor.find_by_login(current_subdomain || params[:id], :visible => true)
      Fetcher::User.send_later(:fetch, params[:id])
      return render :not_found, :status => 404
    end

    @contributions = @contributor.visible_contributions_with_projects
  end
end

class ContributorsController < ApplicationController
  def index
    @contributors = Contributor.all(:login => {'$ne' => ''}, :visible => true)
  end

  def show
    unless @contributor = Contributor.find_by_login(params[:id], :visible => true)
      Fetcher::User.send_later(:fetch, params[:id])
      return render :not_found, :status => 404
    end

    @contributions = @contributor.visible_contributions_with_projects
  end
end

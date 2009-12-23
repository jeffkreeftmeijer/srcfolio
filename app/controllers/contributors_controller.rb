class ContributorsController < ApplicationController
  def index
    @contributors = Contributor.all
  end

  def show
    unless @contributor = Contributor.find_by_login(params[:id])
      return render :not_found, :status => 404
    end
    @contributions = Project.find @contributor.contributions.map{ |c| c['project'] }
  end
end
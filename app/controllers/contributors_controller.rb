class ContributorsController < ApplicationController
  def show
    if @contributor = Contributor.find_by_login(params[:id])
      @contributions = @contributor.contributions
    else
      render :not_found, :status => 404
    end
  end
end
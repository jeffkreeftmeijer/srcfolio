class ContributorsController < ApplicationController
  def show
    unless @contributor = Contributor.find_by_login(params[:id])
      render :not_found, :status => 404
    end
  end
end
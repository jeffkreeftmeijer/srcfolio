class ContributorsController < ApplicationController
  def show
    @contributor = Contributor.find_by_login(params[:id])
  end
end
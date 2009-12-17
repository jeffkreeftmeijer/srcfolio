class ContributorsController < ApplicationController
  def show
    @contributor = Contributor.find(params[:id])
  end
end
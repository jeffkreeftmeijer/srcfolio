class ContributorsController < ApplicationController
  def index
    @contributors = Contributor.all(
      :login =>   {'$ne' => ''},
      :email =>   {'$ne' => ''},
      :visible => true,
      :limit =>   12,
      :order =>   'updated_at desc'
    )
  end

  def show
    id = current_subdomain || params[:id]
    unless @contributor = Contributor.find_by_login(id, :visible => true)
      Fetcher::User.send_later(:fetch, id)
      return render :not_found, :status => 404
    end

    @contributions = @contributor.visible_contributions_with_projects
  end
end

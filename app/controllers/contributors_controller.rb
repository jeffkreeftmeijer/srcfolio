class ContributorsController < ApplicationController
  def index
    @contributors = Contributor.all('login' => {'$ne' => ''})
  end

  def show
    unless @contributor = Contributor.find_by_login(params[:id])
      return render :not_found, :status => 404
    end

    @contributions = @contributor.contributions.map{|c| c.merge({'project' => Project.find(c['project'])})}.select{|c| c['project'].visible? }
    @ownerships =    @contributor.ownerships.map{|o| o.merge({'project' => Project.find(o['project'])})}.select{|c| c['project'].visible? }
    @memberships =   @contributor.memberships.map{|m| m.merge({'project' => Project.find(m['project'])})}.select{|c| c['project'].visible?}

    @memberships.each do |membership|
      @memberships.delete(membership) if @contributions.map{|c| c['project'].id}.include? membership['project'].id
    end

    @ownerships.each do |ownership|
      @ownerships.delete(ownership) if @contributions.map{|c| c['project'].id}.include? ownership['project'].id
    end
  end
end

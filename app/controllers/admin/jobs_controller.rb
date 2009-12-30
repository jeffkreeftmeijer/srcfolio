class Admin::JobsController < ApplicationController
  layout 'admin'
  def index
    @jobs = Delayed::Job.all(:order => 'created_at')
  end
end
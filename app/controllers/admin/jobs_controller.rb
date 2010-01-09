class Admin::JobsController < ApplicationController
  before_filter :authenticate
  
  layout 'admin'
  def index
    @jobs = Delayed::Job.all(:order => 'created_at')
  end
end
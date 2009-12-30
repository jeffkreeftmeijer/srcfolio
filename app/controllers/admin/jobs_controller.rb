class Admin::JobsController < ApplicationController
  layout 'admin'
  def index
    @jobs = Delayed::Job.all
  end
end
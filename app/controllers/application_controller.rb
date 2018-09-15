class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :authenticate_user!

  private

  def authenticate_user!
    return if logged_in?
    render "shared/login"
  end
end

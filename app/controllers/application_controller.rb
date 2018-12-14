class ApplicationController < ActionController::Base
  include SessionsHelper

  before_action :authenticate_user!

  private

  def authenticate_user!
    return if logged_in?
    render "shared/login", layout: false
  end

  def ensure_reviewer!
    return if current_user.reviewer?

    respond_to do |format|
      format.html{redirect_to root_path}
      format.js{head :forbidden}
      format.json{head :forbidden}
    end
  end
end

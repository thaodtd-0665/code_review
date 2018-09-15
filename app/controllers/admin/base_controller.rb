class Admin::BaseController < ApplicationController
  before_action :ensure_reviewer!

  private

  def ensure_reviewer!
    return if current_user.reviewer?
    redirect_to root_path
  end
end

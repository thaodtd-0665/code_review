class OmniauthCallbacksController < ApplicationController
  skip_before_action :authenticate_user!

  def create
    auth = request.env["omniauth.auth"]
    user = AuthenticationService.call auth, current_user

    if user
      log_in user
      flash[:success] = t ".success", kind: auth.provider.humanize
    else
      flash[:error] = t ".failure", kind: params[:provider].humanize
    end

    redirect_to root_path
  end
end

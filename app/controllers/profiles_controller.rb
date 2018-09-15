class ProfilesController < ApplicationController
  def show; end

  def update
    if current_user.update user_params
      flash[:success] = "Updated"
    else
      flash[:danger] = "Update failed"
    end

    redirect_to profile_path
  end

  def destroy
    log_out
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit :room_id
  end
end

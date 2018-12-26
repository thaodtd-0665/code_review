module SessionsHelper
  def log_in user
    cookies.encrypted[:user_id] = user.id
    session[:user_id] = user.id
  end

  def current_user
    return unless session[:user_id]
    @current_user ||= User.find_by id: session[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    cookies.delete :user_id
    session.delete :user_id
    @current_user = nil
  end
end

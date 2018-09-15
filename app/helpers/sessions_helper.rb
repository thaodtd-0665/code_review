module SessionsHelper
  def log_in user
    cookies.encrypted[:user_id] = {value: user.id, expires: 3.days}
  end

  def current_user
    return unless cookies.encrypted[:user_id]
    @current_user ||= User.find_by id: cookies.encrypted[:user_id]
  end

  def logged_in?
    current_user.present?
  end

  def log_out
    cookies.delete :user_id
    @current_user = nil
  end
end

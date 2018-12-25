class AdminConstraint
  def matches? request
    return unless request.session[:user_id].present?
    user = User.find_by id: request.session[:user_id]
    user&.admin?
  end
end

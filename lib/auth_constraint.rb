# Constraint used in routing for hosted routed apps
#
# https://github.com/mperham/sidekiq/wiki/Monitoring
#

class AuthConstraint
  def matches? request
    return false unless request.session[:user_id]

    user = User.find_by id: request.session[:user_id]
    user&.admin?
  end
end

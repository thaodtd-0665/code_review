class Admin::PullRequestsController < Admin::BaseController
  before_action :load_pull_request, only: :update

  def index
    @pull_requests = PullRequest.joins(:user).includes(:user)
                                .by_state(params[:state])
                                .by_room(params[:room])
                                .newest
                                .page params[:page]

    respond_to :html, :js
  end

  def update
    if @pull_request.update pull_request_params
      respond_to :js
    else
      head :bad_request
    end
  end

  private

  def load_pull_request
    @pull_request = PullRequest.find_by id: params[:id]
    return if @pull_request
    head :not_found
  end

  def pull_request_params
    data = params.require(:pull_request).permit :state
    data.merge current_reviewer: current_user.name
  end
end

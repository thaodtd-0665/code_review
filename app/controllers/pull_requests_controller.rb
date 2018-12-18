class PullRequestsController < ApplicationController
  before_action :ensure_reviewer!, only: %i[index status update]
  before_action :load_pull_request, only: :update

  def index
    @pull_requests = PullRequest.left_outer_joins(:user)
                                .by_state(helpers.selected_states)
                                .by_room(helpers.selected_rooms)
                                .by_repository(helpers.selected_repositories)
                                .newest.page params[:page]

    respond_to do |format|
      format.html
      format.js{save_session}
    end
  end

  def status
    count = PullRequest.left_outer_joins(:user)
                       .by_state([:ready])
                       .by_room(helpers.selected_rooms)
                       .by_repository(helpers.selected_repositories)
                       .count

    render json: {
      count: count
    }
  end

  def update
    if pull_request.update pull_request_params
      respond_to :js
    else
      head :bad_request
    end
  end

  private
  attr_reader :pull_request

  def save_session
    current_user.update last_states: helpers.selected_states,
      last_rooms: helpers.selected_rooms,
      last_repositories: helpers.selected_repositories
  end

  def load_pull_request
    @pull_request = PullRequest.find_by id: params[:id]
    return if pull_request
    head :not_found
  end

  def pull_request_params
    data = params.require(:pull_request).permit :state
    data.merge current_reviewer: current_user.name
  end
end

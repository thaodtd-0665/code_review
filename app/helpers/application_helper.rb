module ApplicationHelper
  def github_app_url
    app_name = ENV.fetch("GITHUB_APP_NAME"){""}
    "https://github.com/apps/#{app_name}/installations/new"
  end

  def state_options
    selected = params[:state] ? params[:state].to_i : 1
    options_for_select PullRequest.states, selected
  end

  def room_options
    selected = current_user.room_id || params[:room_id].to_i
    options_from_collection_for_select Room.all, :id, :name, selected
  end
end

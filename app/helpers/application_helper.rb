module ApplicationHelper
  def github_app_url
    app_name = ENV.fetch("GITHUB_APP_NAME"){""}
    "https://github.com/apps/#{app_name}/installations/new"
  end

  def state_options
    selected = params[:state].nil? ? 1 : params[:state].to_i
    options_for_select PullRequest.states, selected
  end

  def room_options
    selected = params[:room].nil? ? current_user.room_id : params[:room].to_i
    options_from_collection_for_select Room.all, :id, :name, selected
  end
end

module ApplicationHelper
  def github_app_url
    app_name = ENV.fetch("GITHUB_APP_NAME"){""}
    "https://github.com/apps/#{app_name}/installations/new"
  end

  def selected_states
    if params[:state].nil?
      current_user.last_states
    else
      params[:state].to_a.reject(&:blank?)
    end
  end

  def selected_room
    if params[:room].nil?
      current_user.last_room
    else
      params[:room].to_s
    end
  end

  def selected_repositories
    if params[:repository].nil?
      current_user.last_repositories
    else
      params[:repository].to_a.reject(&:blank?)
    end
  end

  def state_options
    options_for_select PullRequest.states, selected_states
  end

  def room_options
    options_from_collection_for_select Room.all, :id, :name, selected_room
  end

  def repository_options
    repositories = PullRequest.distinct
                              .order(full_name: :asc)
                              .select :repository_id, :full_name
    options_from_collection_for_select repositories,
      :repository_id, :full_name, selected_repositories
  end
end

module ApplicationHelper
  def full_title page_title = ""
    base_title = "Code Review - Install and forget"

    if page_title.empty?
      base_title
    else
      "#{page_title} | #{base_title}"
    end
  end

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

  def selected_rooms
    if params[:room].nil?
      current_user.last_rooms
    else
      params[:room].to_a.reject(&:blank?)
    end
  end

  def selected_repositories
    if params[:repository].nil?
      current_user.last_repositories
    else
      params[:repository].to_a.reject(&:blank?)
    end
  end

  def selected_languages
    if params[:language].nil?
      current_user.last_languages
    else
      params[:language].to_a.reject(&:blank?)
    end
  end

  def state_options
    options_for_select PullRequest.states, selected_states
  end

  def room_options
    options_from_collection_for_select Room.all, :id, :name, selected_rooms
  end

  def repository_options
    repositories = Repository.where(id: selected_repositories)
                             .order(created_at: :desc)
                             .select :id, :full_name
    options_from_collection_for_select repositories,
      :id, :full_name, repositories.ids
  end

  def language_options
    options_for_select User.languages, selected_languages
  end
end

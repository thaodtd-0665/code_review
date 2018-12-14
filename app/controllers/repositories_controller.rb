class RepositoriesController < ApplicationController
  before_action :ensure_reviewer!, only: %i[index]

  def index
    repositories = Repository.search_by_full_name(params[:term])
                             .select(:id, :full_name)
                             .order(created_at: :desc)
                             .page(params[:page]).per(10)

    render json: {
      results: repositories.as_json(only: [:id], methods: [:text]),
      pagination: {more: !repositories.last_page?}
    }
  end
end

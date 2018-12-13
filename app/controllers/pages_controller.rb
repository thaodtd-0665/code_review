class PagesController < ApplicationController
  def index
    @pull_requests = current_user.pull_requests
                                 .by_single_state(params[:state])
                                 .newest
                                 .page(params[:page]).per 10

    @users = User.select_merged
                 .merged_great_than(0)
                 .order(merged: :desc).limit 5

    respond_to :html, :js
  end
end

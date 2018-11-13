class PagesController < ApplicationController
  def index
    @pull_requests = current_user.pull_requests
                                 .by_single_state(params[:state])
                                 .newest
                                 .page(params[:page]).per 10

    respond_to :html, :js
  end

end

class PagesController < ApplicationController
  def index
    @list_user = PullRequest.merged.in_this_month
                           .group(:user_id).limit(10)
                           .count :user_id
    @users = User.includes(:room).where id: @list_user.keys
  end
end

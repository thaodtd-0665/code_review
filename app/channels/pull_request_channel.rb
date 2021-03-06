class PullRequestChannel < ApplicationCable::Channel
  def subscribed
    stream_from "pull_requests"
  end

  def unsubscribed
    stop_all_streams
  end
end

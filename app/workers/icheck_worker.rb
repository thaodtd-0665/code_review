class IcheckWorker
  include Sidekiq::Worker

  def perform params
    pull_requests = PullRequest.need_check params[:repository_id]
    pull_requests.each(&:auto_state)
  end
end

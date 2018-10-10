class IcheckWorker
  include Sidekiq::Worker

  def perform repo_id
    pull_requests = PullRequest.need_check repo_id
    pull_requests.each(&:auto_state)
  end
end

class ConflictWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1

  def perform repo_id
    pull_request = PullRequest.where(repository_id: repo_id, state: :ready)
                              .order(number: :asc)
                              .first
    return unless pull_request
    ConflictService.call pull_request
  end
end

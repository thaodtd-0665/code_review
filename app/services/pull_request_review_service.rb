class PullRequestReviewService
  def initialize payload
    @payload = payload
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    user = User.find_by id: review_user_id
    return unless user&.reviewer?

    @pull_request = PullRequest.find_or_initialize_by pull_request_params
    return if pull_request.state_merged? || pull_request.state_closed?

    pull_request.assign_attributes pull_request_info
    pull_request.save || pull_request.errors.full_messages.to_sentence
  end

  private
  attr_reader :payload, :pull_request

  def valid?
    payload[:action] == "submitted" || return
    payload[:review][:state] == "commented" || return
  end

  def review_user_id
    @review_user_id ||= payload[:review][:user][:id]
  end

  def pull_request_params
    @pull_request_params ||= {
      repository_id: payload[:repository][:id],
      number: payload[:pull_request][:number]
    }
  end

  def pull_request_info
    @pull_request_info ||= {
      full_name: payload[:repository][:full_name],
      title: payload[:pull_request][:title],
      user_id: payload[:pull_request][:user][:id],
      state: :commented,
      message: payload[:review][:body]
    }
  end
end

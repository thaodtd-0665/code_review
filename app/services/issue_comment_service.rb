class IssueCommentService
  attr_reader :payload, :pull_request

  def initialize payload
    @payload = payload
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    @pull_request = PullRequest.find_by pull_request_params
    return if pull_request.nil? || pull_request.state_closed?

    if issue_user_id == comment_user_id
      normal_issue_command
    else
      review_issue_command
    end
  end

  private

  def valid?
    payload[:action] == "created" && payload[:issue][:pull_request].present?
  end

  def command_valid?
    %w[commented conflicted merged].include? comment.command
  end

  def issue_user_id
    @issue_user_id ||= payload[:issue][:user][:id]
  end

  def comment_user_id
    @comment_user_id ||= payload[:comment][:user][:id]
  end

  def comment_body
    @comment_body ||= payload[:comment][:body]
  end

  def pull_request_params
    @pull_request_params ||= {
      repository_id: payload[:repository][:id],
      number: payload[:issue][:number]
    }
  end

  def comment
    @comment ||= CommentScope.new comment_body
  end

  def normal_issue_command
    return if pull_request.state_reviewing?
    return unless comment.command_ready?

    pull_request.assign_attributes state: :ready
    pull_request.save || pull_request.errors.full_messages.to_sentence
  end

  def review_issue_command
    return unless command_valid?

    user = User.find_by id: comment_user_id
    return unless user&.reviewer?

    pull_request.assign_attributes comment.command_message
    pull_request.save || pull_request.errors.full_messages.to_sentence
  end
end

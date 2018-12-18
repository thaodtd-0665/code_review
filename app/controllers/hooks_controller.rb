class HooksController < ActionController::API
  wrap_parameters format: []

  before_action :check_signature!, only: :create

  def create
    payload = JSON.parse raw_post, symbolize_names: true

    plain =
      case request.headers["X-GitHub-Event"]
      when "installation", "integration_installation"
        InstallationService.call payload
      when "installation_repositories", "integration_installation_repositories"
        InstallationRepositoryService.call payload
      when "repository"
        RepositoryService.call payload
      when "pull_request"
        PullRequestService.call payload
      when "pull_request_review"
        PullRequestReviewService.call payload
      when "issue_comment"
        IssueCommentService.call payload
      else
        "Unmatch!"
      end

    render plain: plain
  end

  private

  attr_reader :raw_post

  def check_signature!
    @raw_post = request.raw_post
    signed = sign_data raw_post
    # TODO: secure_compare
    return if request.headers["X-Hub-Signature"] == "sha1=#{signed}"
    render plain: "Signatures didn't match!"
  end

  def sign_data body
    digest = OpenSSL::Digest::SHA1.new
    OpenSSL::HMAC.hexdigest digest, ENV["GITHUB_WEBHOOK_SECRET"], body
  end
end

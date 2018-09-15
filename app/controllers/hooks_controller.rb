class HooksController < ActionController::API
  wrap_parameters format: []

  before_action :check_signature!, only: :create

  def create
    event = request.headers["X-GitHub-Event"]
    payload = JSON.parse raw_post, symbolize_names: true
    plain = "#{event}_service".classify.constantize.call payload
    render plain: plain
  end

  private

  attr_reader :raw_post

  def check_signature!
    @raw_post = request.raw_post
    signed = sign_data raw_post
    # TODO: secure_compare
    return if request.headers["X-Hub-Signature"] == "sha1=#{signed}"
    render html: "Signatures didn't match!"
  end

  def sign_data body
    digest = OpenSSL::Digest::SHA1.new
    OpenSSL::HMAC.hexdigest digest, ENV["GITHUB_WEBHOOK_SECRET"], body
  end
end

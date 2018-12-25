module HooksHelper
  def sig_data content
    digest = OpenSSL::Digest::SHA1.new
    secret = ENV["GITHUB_WEBHOOK_SECRET"]
    OpenSSL::HMAC.hexdigest digest, secret, content
  end
end

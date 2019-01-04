class ConflictService
  BASE_URL = "https://api.github.com/repos/".freeze

  def initialize pull_request
    @pull_request = pull_request
  end

  def self.call *args
    new(*args).call
  end

  def call
    5.times do
      status = mergeable

      if status.nil?
        sleep 1
        next
      end

      conflicted if status == false
      break
    end
  end

  private
  attr_reader :pull_request

  def conflicted
    pull_request.update state: :conflicted, message: I18n.t(:conflict_detected)
  end

  def url
    @url ||= "#{BASE_URL}#{pull_request.full_name}/pulls/#{pull_request.number}" +
             "?client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"
  end

  def mergeable
    resp = Excon.get url
    data = JSON.parse resp.body
    data["mergeable"]
  end
end

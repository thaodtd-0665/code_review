class ConflictService
  BASE_URL = "https://api.github.com/repos/".freeze

  def initialize pull_request
    @pull_request = pull_request
  end

  def self.call *args
    new(*args).call
  end

  def call
    status = mergeable

    return conflicted if status == false
    status.nil? || return
    sleep 3
    conflicted if mergeable == false
  end

  private
  attr_reader :pull_request

  def conflicted
    pull_request.update state: :conflicted, message: "(devil) autobot"
  end

  def url
    @url ||= "#{BASE_URL}#{pull_request.full_name}/pulls/#{pull_request.number}" +
             "?client_id=#{ENV['GITHUB_CLIENT_ID']}&client_secret=#{ENV['GITHUB_CLIENT_SECRET']}"
  end

  def mergeable
    resp = Excon.get url
    data = JSON.parse resp.body
    puts resp.body
    puts resp.headers
    data["mergeable"]
  end
end

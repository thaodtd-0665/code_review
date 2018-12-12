class RepositoryService
  def initialize payload
    @payload = payload
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    PullRequest.where(repository_id: repository_id).delete_all
  end

  private
  attr_reader :payload

  def valid?
    %w[deleted].include? payload[:action]
  end

  def repository_id
    @repository_id ||= payload[:repository][:id]
  end
end

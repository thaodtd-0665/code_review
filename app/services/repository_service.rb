class RepositoryService
  ACTIONS = %w[created deleted].freeze

  def initialize payload
    @payload = payload
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    repository = Repository.find_by id: repository_params[:id]
    return repository&.destroy if deleted?
    Repository.create(repository_params) unless repository
  end

  private
  attr_reader :payload

  def valid?
    ACTIONS.include? payload[:action]
  end

  def deleted?
    payload[:action] == "deleted"
  end

  def repository_params
    @repository_params ||= payload[:repository].slice :id, :full_name
  end
end

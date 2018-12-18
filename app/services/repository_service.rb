class RepositoryService
  def initialize payload
    @payload = payload
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    repository = Repository.find_by id: repository_params[:id]
    return if repository

    Repository.create repository_params
  end

  private
  attr_reader :payload

  def valid?
    payload[:action] == "created"
  end

  def repository_params
    @repository_params ||= payload[:repository].slice :id, :full_name
  end
end

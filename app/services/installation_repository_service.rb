class InstallationRepositoryService
  COLUMNS = %i[id full_name].freeze

  def initialize payload
    @payload = payload
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    Repository.import COLUMNS, repositories, on_duplicate_key_ignore: true
  end

  private
  attr_reader :payload

  def valid?
    %w[added].include? payload[:action]
  end

  def repositories
    @repositories ||= payload[:repositories_added].pluck :id, :full_name
  end
end

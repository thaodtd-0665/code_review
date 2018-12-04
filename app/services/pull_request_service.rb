class PullRequestService
  attr_reader :payload

  EMOTICONS = [
    "(tat)", "(tat2)", "(2tat)", "(tat3)", "(tat4)", "(tat5)",
    "(tat6)", "(tat7)", "(tat8)", "(chem)", "(dam)", "(dam2)",
    "(dap)", "(dap2)", "(lengoi)", "(songphi)", "(sml)",
    "(songphi2)", "(va)", "(phanno)", "(hate)",
    "(chetdi)"
  ].freeze

  def initialize payload
    @payload = payload
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    pull_request = PullRequest.find_or_initialize_by pull_request_params
    pull_request.assign_attributes pull_request_info
    pull_request.save || pull_request.errors.full_messages.to_sentence
  end

  private

  def valid?
    %w[opened closed reopened].include? payload[:action]
  end

  def pull_request_params
    @pull_request_params ||= {
      repository_id: payload[:repository][:id],
      number: payload[:pull_request][:number]
    }
  end

  def pull_request_info
    @pull_request_info ||= {
      title: payload[:pull_request][:title],
      full_name: payload[:repository][:full_name],
      user_id: payload[:pull_request][:user][:id],
      state: pull_request_state,
      message: watching_you
    }
  end

  def pull_request_state
    return "merged" if payload[:pull_request][:merged]
    payload[:pull_request][:state]
  end

  def pull_request_commits
    @pull_request_commits ||= payload[:pull_request][:commits]
  end

  def changed_files
    @changed_files ||= payload[:pull_request][:changed_files]
  end

  def watching_you
    messages = []
    messages.push I18n.t("pull_requests.commits") if pull_request_commits > 1
    messages.push I18n.t("pull_requests.changed_files") if changed_files > 15
    messages.push EMOTICONS.sample if messages.length.positive?
    messages.join "\n"
  end
end

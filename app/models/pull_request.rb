class PullRequest < ApplicationRecord
  attr_accessor :message

  enum state: %i[open ready reviewing commented conflicted merged closed],
    _prefix: true

  belongs_to :user, optional: true

  before_save :remove_current_reviewer, on: :update
  after_create_commit{sync_data}
  after_update_commit{sync_data if previous_changes.key?(:state)}
  after_update_commit{check_data}

  scope :newest, ->{order updated_at: :desc}

  scope :by_state, (lambda do |state_param|
    where state: state_param if state_param.any?
  end)

  scope :by_room, (lambda do |room_param|
    where users: {room_id: room_param} if room_param.any?
  end)

  scope :by_repository, (lambda do |repository_param|
    where repository_id: repository_param if repository_param.any?
  end)

  scope :need_check, (lambda do |repository_param|
    where repository_id: repository_param, state: :ready
  end)

  delegate :name, :room_id, :chatwork, :html_url,
    to: :user, prefix: true, allow_nil: true

  def auto_state
    url = "https://api.github.com/repos/#{full_name}/pulls/#{number}"

    res = Excon.get url
    json = JSON.parse res.body, symbolize_names: true

    state_conflicted! if json[:mergeable] == false
  end

  def html_url
    "https://github.com/#{full_name}/pull/#{number}/files"
  end

  def html_path
    "#{full_name}/pull/#{number}/files"
  end

  def repository_html_url
    "https://github.com/#{full_name}"
  end

  private

  def remove_current_reviewer
    self.current_reviewer = nil unless state_reviewing?
  end

  def sync_data
    ActionCable.server.broadcast "pull_requests",
      node: "#pull-request-#{id}",
      state: state_before_type_cast.to_s,
      room_id: user_room_id.to_s,
      repository_id: repository_id.to_s,
      html: PullRequestsController.render(self)

    ChatworkService.call self, message
  end

  def check_data
    return unless previous_changes.key?(:state) && state_merged?

    user&.increment! :merged
    IcheckWorker.perform_async repository_id
  end
end

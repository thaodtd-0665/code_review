class PullRequest < ApplicationRecord
  attr_accessor :message

  enum state: %i[open ready reviewing commented conflicted merged closed],
    _prefix: true

  belongs_to :user, optional: true

  before_save :remove_current_reviewer, on: :update
  after_create_commit{sync_data}

  after_update_commit do
    previous_changes.key?(:state) || return
    sync_data

    # state_merged? || return
    # user&.increment! :merged
  end

  scope :newest, ->{order updated_at: :desc}

  scope :by_state, (lambda do |state_param|
    state_param = state_param.present? ? state_param.to_i : 1
    where state: state_param
  end)

  scope :by_room, (lambda do |room_param|
    where users: {room_id: room_param.to_i} if room_param.present?
  end)

  scope :by_repository, (lambda do |repository_param|
    repository_param = repository_param.reject &:blank?
    where repository_id: repository_param if repository_param.any?
  end)

  delegate :name, :room_id, :chatwork, :html_url,
    to: :user, prefix: true, allow_nil: true

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
end

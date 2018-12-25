class PullRequest < ApplicationRecord
  attr_accessor :message

  STATES = {
    open: 0,
    ready: 1,
    reviewing: 2,
    commented: 3,
    conflicted: 4,
    merged: 5,
    closed: 6,
    archived: 7
  }.freeze

  enum state: STATES, _prefix: true

  belongs_to :user, optional: true

  before_save :delete_current_reviewer, on: :update
  after_commit :broadcast_content # TODO
  after_create_commit :subscribe_repository
  after_create_commit :send_message
  after_update_commit :send_message, if: :previous_change_state?
  after_update_commit :increment_merged, if: :state_change_to_merged?

  scope :newest, ->{order updated_at: :desc}

  scope :by_single_state, (lambda do |state_param|
    where state: state_param.to_i unless state_param.blank?
  end)

  scope :by_state, (lambda do |state_param|
    where state: state_param if state_param.any?
  end)

  scope :by_room, (lambda do |room_param|
    where users: {room_id: room_param} if room_param.any?
  end)

  scope :by_repository, (lambda do |repository_param|
    where repository_id: repository_param if repository_param.any?
  end)

  delegate :name, :room_id, :chatwork, :to_cw, :to_cc, :html_url,
    to: :user, prefix: true, allow_nil: true

  def html_path
    "#{full_name}/pull/#{number}"
  end

  def html_url
    "https://github.com/#{html_path}"
  end

  private

  def delete_current_reviewer
    self.current_reviewer = nil unless state_reviewing?
  end

  def broadcast_content
    ActionCable.server.broadcast "pull_requests",
      id: id, deleted: destroyed?,
      state: state_before_type_cast.to_s,
      room_id: user_room_id.to_s,
      repository_id: repository_id.to_s,
      html: PullRequestsController.render(self)
  end

  def subscribe_repository
    Subscription.create repository_id: repository_id,
      user_id: user_id, subscriber: user_to_cc
  end

  def previous_change_state?
    previous_changes.key? :state
  end

  def send_message
    return if state_open? && message.blank?
    return if state_archived?
    return unless user_chatwork && user_room_id

    params = {
      id: id,
      url: html_url,
      state: state,
      repository_id: repository_id,
      number: number,
      reviewer: current_reviewer,
      message: message,
      room_id: user_room_id,
      user_id: user_id,
      user_cw: user_to_cw
    }

    ChatworkWorker.perform_async params
  end

  def state_change_to_merged?
    previous_change_state? && state_merged?
  end

  def increment_merged
    user&.increment! :merged
  end
end

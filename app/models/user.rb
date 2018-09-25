class User < ApplicationRecord
  enum role: %i[normal reviewer]

  store_accessor :settings, :last_states, :last_room, :last_repositories

  belongs_to :room, optional: true
  has_many :pull_requests, dependent: :destroy

  validate :room_vaild, on: :update

  scope :merged_great_than, (lambda do |number_param|
    where arel_table[:merged].gt number_param
  end)

  delegate :name, to: :room, prefix: true, allow_nil: true

  def display_name
    name.blank? ? "@#{login}" : name
  end

  def last_states
    super || [1, 2]
  end

  def last_room
    super || room_id
  end

  def last_repositories
    super.to_a
  end

  def html_url
    "https://github.com/#{login}"
  end

  private

  def room_vaild
    return if room_id.nil? || Room.exists?(room_id)
    errors.add :room_id, :invalid
  end
end

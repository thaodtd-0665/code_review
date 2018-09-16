class User < ApplicationRecord
  enum role: %i[normal reviewer]

  belongs_to :room, optional: true
  has_many :pull_requests, dependent: :destroy

  validate :room_vaild, on: :update

  delegate :name, to: :room, prefix: true, allow_nil: true

  def html_url
    "https://github.com/#{login}"
  end

  private

  def room_vaild
    return if room_id.nil? || Room.exists?(room_id)
    errors.add :room_id, :invalid
  end
end

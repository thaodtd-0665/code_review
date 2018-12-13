class Room < ApplicationRecord
  validates :name, presence: true

  def api_token
    bot_api_token || ENV["CHATWORK_API_TOKEN"]
  end
end

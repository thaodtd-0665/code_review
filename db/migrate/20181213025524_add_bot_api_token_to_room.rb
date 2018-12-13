class AddBotApiTokenToRoom < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :bot_api_token, :string
  end
end

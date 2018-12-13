class ChatworkRoomService
  def initialize access_token
    @access_token = access_token
  end

  def self.call *args
    new(*args).call
  end

  def call
    client = ChatWork::Client.new access_token: access_token

    remote_groups = client.get_rooms.select{|room| room.type == "group"}
    remote_group_ids = remote_groups.pluck :room_id
    Room.where(id: remote_group_ids).pluck :id
  end

  private
  attr_reader :access_token
end

class ChatworkRoomService
  def initialize access_token
    @access_token = access_token
  end

  def self.call *args
    new(*args).call
  end

  def call
    client = ChatWork::Client.new access_token: access_token

    remote_rooms = client.get_rooms.select{|room| room.type == "group"}
    remote_room_ids = remote_rooms.pluck :room_id
    local_room_ids = Room.where(id: remote_room_ids).pluck :id
    local_room_ids.first
  end

  private
  attr_reader :access_token
end

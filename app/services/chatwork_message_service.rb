class ChatworkMessageService
  def initialize pull_request, message
    @pull_request = pull_request
    @message = message
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    room = Room.find_by id: pull_request.user_room_id
    return unless room

    client = ChatWork::Client.new api_key: room.api_token
    client.create_message room_id: room.id, body: body
  end

  private
  attr_reader :pull_request, :message

  def valid?
    return if pull_request.state_open? && message.blank?
    pull_request.user_chatwork && pull_request.user_room_id
  end

  def body
    I18n.t "chatwork.messages.#{pull_request.state}",
      chatwork: chatwork,
      number: pull_request.number,
      reviewer: pull_request.current_reviewer,
      html_url: pull_request.html_url,
      message: message
  end

  def chatwork
    if pull_request.state_ready? || pull_request.state_merged?
      Subscription.list(pull_request.repository_id, pull_request.user_id)
                  .pluck(:subscriber)
                  .unshift(pull_request.user_to_cw)
                  .join "\n"
    else
      pull_request.user_to_cw
    end
  end
end

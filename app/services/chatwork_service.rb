class ChatworkService
  attr_reader :pull_request, :message

  def initialize pull_request, message
    @pull_request = pull_request
    @message = message
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?

    body = I18n.t "chatwork.message", name: pull_request.user_name,
      chatwork: pull_request.user_chatwork,
      number: pull_request.number,
      state: pull_request.state,
      html_url: pull_request.html_url,
      message: message

    client = ChatWork::Client.new api_key: ENV["CHATWORK_API_TOKEN"]
    client.create_message room_id: pull_request.user_room_id, body: body
  end

  private

  def valid?
    pull_request.user_chatwork && pull_request.user_room_id
  end
end

class ChatworkWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3

  def perform params
    params = params.with_indifferent_access
    room = Room.find params[:room_id]
    client = ChatWork::Client.new api_key: room.api_token
    client.create_message room_id: room.id, body: template(params)
  end

  private

  def template params
    chatwork = \
      if params[:state] == "merged"
        Subscription.list(params[:repository_id], params[:user_id])
                    .pluck(:subscriber)
                    .unshift(params[:user_cw])
                    .join "\n"
      else
        params[:user_cw]
      end

    locals = params.slice(:number, :reviewer, :url, :message)
                   .merge chatwork: chatwork

    I18n.t "chatwork.messages.#{params[:state]}", locals
  end
end

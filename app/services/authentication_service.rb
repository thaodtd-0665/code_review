class AuthenticationService
  def initialize auth, current_user
    @auth = auth
    @current_user = current_user
  end

  def self.call *args
    new(*args).call
  end

  def call
    return unless valid?
    send "handle_#{auth.provider}"
  end

  private
  attr_reader :auth, :current_user

  def valid?
    auth.provider.present? || return
    auth.uid.present? || return
  end

  def handle_github
    user = User.find_or_initialize_by id: auth.uid
    user.assign_attributes login: auth.info.nickname
    user.save! || return
    user
  end

  def handle_chatwork
    return unless current_user
    current_user.assign_attributes user_params
    current_user.save! || return
    current_user
  end

  def user_params
    @user_params ||= {
      name: auth.info.name,
      avatar: auth.info.image,
      email: auth.info.email,
      chatwork: auth.uid,
      room_id: room_id
    }
  end

  def room_id
    room_ids = ChatworkRoomService.call auth.credentials.token
    room_ids.length == 1 ? room_ids.first : nil
  end
end

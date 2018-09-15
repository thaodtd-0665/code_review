class CommentScope
  attr_reader :comment, :command, :message

  def initialize comment
    @comment = comment
    @command = lines.shift.downcase.strip
    @message = lines.join boundary
  end

  def command_ready?
    command == "ready"
  end

  def command_message
    @command_message ||= {
      state: command,
      message: message
    }
  end

  private

  def lines
    @lines ||= comment.split boundary
  end

  def boundary
    "\r\n"
  end
end

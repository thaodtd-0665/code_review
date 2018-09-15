class Rack::Webhooks
  def initialize app
    @app = app
  end

  def call env
    env["CONTENT_TYPE"] = "text/plain" if match?(env)
    @app.call env
  end

  private

  def match? env
    request = Rack::Request.new env
    request.path_info == "/hooks"
  end
end

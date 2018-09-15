# This file is used by Rack-based servers to start the application.

require_relative "config/environment"
require_relative "lib/webhooks"

use Rack::Webhooks
run Rails.application

#!/usr/bin/env puma

directory "/usr/local/rails_apps/code_review_production/current"
rackup "/usr/local/rails_apps/code_review_production/current/config.ru"

# Default to production
rails_env = "production"
environment rails_env

pidfile "/usr/local/rails_apps/code_review_production/shared/tmp/pids/puma.pid"
state_path "/usr/local/rails_apps/code_review_production/shared/tmp/pids/puma.state"
stdout_redirect "/usr/local/rails_apps/code_review_production/shared/log/puma_access.log",
                "/usr/local/rails_apps/code_review_production/shared/log/puma_error.log", true

threads 1,6
port 3030

bind "unix:///usr/local/rails_apps/code_review_production/shared/tmp/sockets/puma.sock"

workers 4

plugin :tmp_restart

prune_bundler

on_restart do
  puts "Refreshing Gemfile"
  ENV["BUNDLE_GEMFILE"] = "/usr/local/rails_apps/code_review_production/current/Gemfile"
end

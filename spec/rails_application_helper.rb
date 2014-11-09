require "action_controller/railtie"

class Application < Rails::Application
  config.secret_key_base = 'bogus'
end

require 'rspec/rails'
require 'rspec/rails/example'

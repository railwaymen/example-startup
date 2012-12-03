env_config = File.join(Rails.root, 'config', 'env_config.rb')
load(env_config) if File.exists?(env_config)

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
ExampleStartup::Application.initialize!

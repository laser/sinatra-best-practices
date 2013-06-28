ENV['RACK_ENV'] ||= 'development'

require 'bundler'
Bundler.require :default, ENV['RACK_ENV'].to_sym

require_relative 'helpers'
require_relative 'routes/secrets'
require_relative 'routes/sessions'

class SimpleApp < Sinatra::Base
  # Sinatra looks for a 'views' subdirectory of root
  set :root, File.dirname(__FILE__)

  enable :sessions

  helpers Sinatra::SampleApp::Helpers

  register Sinatra::SampleApp::Routing::Sessions
  register Sinatra::SampleApp::Routing::Secrets
end

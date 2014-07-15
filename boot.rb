require 'rubygems'
require 'bundler'
require 'active_support/all'

Bundler.require :default, :assets, (ENV['RACK_ENV'] || 'development').to_sym

Faye::WebSocket.load_adapter('thin')

%w(base asset_pipeline).each { |name| require("sinatra/#{name}") }

ROOT_PATH = File.dirname(__FILE__)
CONFIGURATION = YAML.load_file(File.join(ROOT_PATH, 'config.yml')).with_indifferent_access

%w(lib helpers).each do |path|
  Dir[File.join(ROOT_PATH, path, '*.rb')].each { |file| require(file) }
end

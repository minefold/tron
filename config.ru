require 'bundler/setup'

$:.unshift File.expand_path('../lib', __FILE__)
$:.unshift File.expand_path('../app', __FILE__)
require './app'
run Sinatra::Application

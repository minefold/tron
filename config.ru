require 'bundler/setup'
require './app'

map "/" do
  run Sinatra::Application
end

map "/sidekiq" do
  require 'sidekiq/web'
  run Sidekiq::Web
end
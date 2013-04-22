%w(./lib ./app).each do |path|
  $LOAD_PATH.unshift File.expand_path(File.join('..', path), __FILE__)
end

require 'bundler/setup'
require 'sidekiq'
require 'sequel'

DB = Sequel.connect(ENV['DATABASE_URL'],
  encoding: 'utf-8',
  max_connections: 10
)

Sequel.default_timezone = :utc
Sequel::Model.unrestrict_primary_key
Sequel::Model.plugin :validation_helpers
Sequel::Model.plugin :timestamps, :update_on_create => true,
                                  :create => :created,
                                  :update => :updated

require 'models'
require 'jobs'

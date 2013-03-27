require 'models/player'

class Server < Sequel::Model
  many_to_one :account
  many_to_one :funpack
  many_to_one :owner, class: Player
end

require 'models/player'
require 'state_machine/core'

class Server < Sequel::Model
  extend StateMachine::MacroMethods

  States = {
    down: 0,
    up: 1,
    crashed: 2
  }

  many_to_one :account
  many_to_one :funpack
  many_to_one :owner, class: Player
  many_to_one :snapshot

  one_to_many :sessions

  one_to_one( :session) {|ds| ds.where(stopped: nil) }

  state_machine(:initial => :down) do
    States.each {|name, value| state(name, value: value) }

    event(:start) { transition([:down, :up] => :up) }
    event(:stop) { transition([:up, :down] => :down) }
  end

end

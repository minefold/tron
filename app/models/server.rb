require 'models/player'
require 'state_machine/core'

class Server < Sequel::Model
  extend StateMachine::MacroMethods

  States = {
    down: 0,
    starting: 1,
    up: 2,
    crashed: 3
  }

  many_to_one :account
  many_to_one :funpack
  many_to_one :region
  many_to_one :owner, class: Player
  many_to_one :snapshot

  one_to_many :sessions

  one_to_one( :session) {|ds| ds.where(stopped: nil) }

  state_machine(:initial => :down) do
    States.each {|name, value| state(name, value: value) }

    event(:start) { transition(any => :starting) }
    event(:started) { transition(any => :up)}
    event(:stop) { transition(any => :down) }
    event(:crashed) { transition(any => :crashed) }
  end

  def validate
    validates_presence [:id, :account, :funpack, :region]
    validates_unique :id
  end

end

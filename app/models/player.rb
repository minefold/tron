require 'models/player_session'
require 'models/session'

class Player < Sequel::Model

  many_to_one :account
  one_to_many :player_sessions
  many_to_many :sessions,
    :join_table => :player_sessions,
    :distinct => true

  def validate
    super
    validates_presence [:id, :account]
    validates_unique :id
  end

end

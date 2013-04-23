class Session < Sequel::Model
  many_to_one :server
  one_to_many :player_sessions

  many_to_many :players,
    :join_table => :player_sessions,
    :distinct => true

  def started?
    not started.nil?
  end

  def stopped?
    not stopped.nil?
  end

  def crashed?
    stopped? and exit_status != 0
  end

end

class PlayerSession < Sequel::Model
  many_to_one :session
  many_to_one :player

  def validate
    super
    validates_presence [:id, :session, :player, :started]
    validates_unique :id
  end

end

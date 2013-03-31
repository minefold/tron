class Funpack < Sequel::Model
  many_to_one :account

  def validate
    validates_presence [:id, :account, :name]
    validates_unique :id, :name
  end

end

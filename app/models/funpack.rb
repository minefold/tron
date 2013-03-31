class Funpack < Sequel::Model
  many_to_one :account
  one_to_many :servers

  def validate
    validates_presence [:id, :account, :name]
    validates_unique :id, :name
  end

end

class Region < Sequel::Model

  def validate
    validates_presence [:id, :name]
    validates_unique :id, :name
  end

end

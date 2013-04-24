class Region < Sequel::Model

  def validate
    super
    validates_presence [:id, :name]
    validates_unique :id, :name
  end

end

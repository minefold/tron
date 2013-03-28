class Session < Sequel::Model
  many_to_one :server

  def started?
    not started.nil?
  end

end

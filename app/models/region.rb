class Region
  attr_reader :id
  attr_reader :created
  attr_reader :lat
  attr_reader :lng

  def initialize(params)
    @id = params.fetch(:id)
    @created = params.fetch(:created)
    @lat = params.fetch(:lat)
    @lng = params.fetch(:lng)
  end
end

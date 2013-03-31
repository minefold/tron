require 'controller'

class RegionsController < Controller

  get '/regions' do
    authenticate!

    regions = Region.all

    json ListSerializer.new(regions.map {|region|
      RegionSerializer.new(region)
    })
  end

end

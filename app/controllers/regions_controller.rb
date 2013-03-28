class RegionsController < Sinatra::Base

  get '/regions' do
    us_east_1 = Region.new(
      id: 'us-east-1',
      created: Time.now.to_i,
      lat: 38.13,
      lng: -78.45
    )

    regions = [us_east_1]

    content_type :json
    ListSerializer.new(regions.map {|region|
      RegionSerializer.new(region)
    }).to_json
  end

end

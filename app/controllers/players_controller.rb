require 'controller'
require 'securerandom'

class PlayersController < Controller

  post '/players' do
    authenticate!
    param :distinctId, String
    param :username, String
    param :email, String

    player = Player.new(
      id: SecureRandom.uuid,
      account: account,
      distinct_id: params[:distinctId],
      username: params[:username],
      email: params[:email]
    )

    if not player.valid?
      halt 422, player.errors
    end

    player.save
    status 201
    json PlayerSerializer.new(player)
  end

  get '/players/:id' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    player = Player.where(id: params[:id], account: account).first

    if player.nil?
      halt 404
    end

    json PlayerSerializer.new(player)
  end

  patch '/players/:id' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    param :distinctId, String
    param :name, String
    param :email, String

    player = Player.where(id: params[:id], account: account).first

    if player.nil?
      halt 404
    end

    # TODO Wrap this in tests and figure out the correct Sequel fn
    player.distinct_id = params[:distinctId] || player.distinct_id
    player.username = params[:username] || player.username
    player.email = params[:email] || player.email

    unless player.valid?
      halt 422, player.errors
    end

    player.save

    json PlayerSerializer.new(player)
  end

  delete '/players/:id' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    player = Player.where(id: params[:id], account: account).first

    if player.nil?
      halt 404
    end

    player.destroy

    halt 204
  end

  get '/players' do
    authenticate!

    players = account.players

    json ListSerializer.new(players.map {|player|
      PlayerSerializer.new(player)
    })
  end

end

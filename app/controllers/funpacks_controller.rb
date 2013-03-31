require 'controller'

class FunpacksController < Controller

  get '/funpacks/:id' do
    authenticate!
    param :id, String, required: true, is: ID_PATTERN, :coerce => :downcase

    funpack = Funpack.where(id: params[:id], account: account).first

    if funpack.nil?
      halt 404
    end

    json FunpackSerializer.new(funpack)
  end

  get '/funpacks' do
    authenticate!

    funpacks = account.funpacks

    json ListSerializer.new(funpacks.map {|funpack|
      FunpackSerializer.new(funpack)
    })
  end

end

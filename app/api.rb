class API < Grape::API
  version 'v1', :using => :header, :vendor => :minefold
  format :json

  helpers do
    def redis
      env.config['redis']
    end

    def pg
      env.config['pg']
    end
  end

  resource :servers do

    get '/:id' do
      server = pg[:servers].where(id: params[:id]).first

      {
        id:   server[:id],
        name: server[:name],
        url:  "/servers/#{server[:id]}",
        createdAt: server[:created_at],
        updatedAt: server[:updated_at],
        state: server[:state],
        address: "#{server[:id]}.fun-#{server[:funpack_id]}.us-east-1.foldserver.com",
        players: redis.smembers("server:#{server[:party_cloud_id]}:players")
      }
    end

  end

end

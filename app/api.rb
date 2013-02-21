class API < Grape::API
  version 'v1', :using => :header, :vendor => :minefold
  format :json

  helpers do
    def redis
      env.config['redis']
    end
  end

  resource :servers do

    get '/:id' do
      redis.get('test')
    end

  end

end

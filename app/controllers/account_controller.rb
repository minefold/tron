require 'controller'

class AccountController < Controller

  get '/account' do
    authenticate!

    json AccountSerializer.new(account)
  end

end

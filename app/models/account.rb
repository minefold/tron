require 'securerandom'

class Account < Sequel::Model

  API_KEY_LENGTH = 32

  one_to_many :funpacks
  one_to_many :servers
  one_to_many :players

  def self.generate_api_key
    # Length is 4/3 the size of the resulting string, obviously!
    SecureRandom.urlsafe_base64(API_KEY_LENGTH * 0.75)
  end

  def self.find_from_auth(auth)
    # Legacy hack for deploy. Please remove.
    if auth.username == 'minefold'
      where(email: 'admin@minefold.com')
    else
      where(api_key: auth.username)
    end.first
  end

  def before_validation
    self.api_key = self.class.generate_api_key
    super
  end

  def validate
    super
    validates_presence [:id, :email, :api_key]
    validates_unique :id, :email, :api_key
    validates_max_length API_KEY_LENGTH, :api_key
  end

  def server_count
    servers_dataset.count
  end

  def up_servers
    servers_dataset.where(state: Server::States[:up])
    # servers_dataset.where(:state == Server::States[:up])
  end

  def server_limit
    5
  end

  def server_limit_remaining
    server_limit - up_servers.count
  end

end

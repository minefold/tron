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
    api_key = if auth.username == 'minefold'
      "31K4xqnzlrhEfIVwgfBrRW2ViT2T65tF"
    else
      auth.username
    end
    where(api_key: api_key).first
  end

  def before_validation
    self.api_key = self.class.generate_api_key
    super
  end

  def validate
    validates_presence [:id, :email, :api_key]
    validates_unique :id, :email, :api_key
    validates_max_length API_KEY_LENGTH, :api_key
  end

end

class Account < ApplicationRecord
  extend Enumerize

  enumerize :state, in: %i[enabled disabled], predicates: true, default: :enabled

  has_one :access_token,
          class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id

  has_many :phone_calls
  has_many :incoming_phone_numbers

  def auth_token
    access_token.token
  end
end

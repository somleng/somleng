class Account < ApplicationRecord
  extend Enumerize

  enumerize :status, in: %i[enabled disabled], predicates: true, default: :enabled

  belongs_to :carrier
  belongs_to :outbound_sip_trunk, optional: true

  has_one :access_token,
          class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id,
          dependent: :destroy

  has_many :phone_calls, dependent: :restrict_with_error
  has_many :incoming_phone_numbers, dependent: :delete_all

  def auth_token
    access_token.token
  end
end

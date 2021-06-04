class Account < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  enumerize :status, in: %i[enabled disabled], predicates: true, default: :enabled

  belongs_to :carrier
  belongs_to :outbound_sip_trunk, optional: true

  has_one :access_token,
          class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id,
          dependent: :destroy

  has_many :phone_calls
  has_many :incoming_phone_numbers
  has_many :account_memberships
  has_many :users, through: :account_memberships

  def auth_token
    access_token.token
  end
end

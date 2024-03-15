class Account < ApplicationRecord
  self.inheritance_column = :_type_disabled

  extend Enumerize

  enumerize :type, in: [ :carrier_managed, :customer_managed ], predicates: true, scope: :shallow
  enumerize :status, in: %i[enabled disabled], predicates: true, default: :enabled

  attribute :default_tts_voice, TTSVoiceType.new

  belongs_to :carrier
  belongs_to :sip_trunk, optional: true

  has_one :access_token,
          class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id,
          dependent: :destroy

  has_many :phone_calls, -> { where(internal: false) }, dependent: :restrict_with_error
  has_many :messages, -> { where(internal: false) }, dependent: :restrict_with_error
  has_many :messaging_services
  has_many :verification_services
  has_many :verifications
  has_many :phone_numbers, dependent: :restrict_with_error
  has_many :account_memberships, dependent: :restrict_with_error
  has_many :users, through: :account_memberships
  has_many :recordings
  has_many :error_logs
  has_many :interactions
  has_many :tts_events

  def auth_token
    access_token.token
  end

  def owner
    account_memberships.owner.first&.user
  end
end

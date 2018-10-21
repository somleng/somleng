class Account < ApplicationRecord
  has_one :access_token,
          class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id

  has_many :phone_calls
  has_many :incoming_phone_numbers
  has_many :recordings, through: :phone_calls, source: :recordings

  store_accessor :settings, :source_matcher

  alias_attribute :sid, :id

  include AASM

  aasm column: :state do
    state :enabled, initial: true
    state :disabled

    event :enable do
      transitions from: :disabled, to: :enabled
    end

    event :disable do
      transitions from: :enabled, to: :disabled
    end
  end

  def auth_token
    access_token&.token
  end
end

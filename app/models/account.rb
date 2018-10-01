class Account < ApplicationRecord
  has_one :access_token,
          class_name: "Doorkeeper::AccessToken",
          foreign_key: :resource_owner_id

  has_many :phone_calls
  has_many :incoming_phone_numbers
  has_many :recordings, through: :phone_calls, source: :recordings

  bitmask :permissions,
          as: %i[
            manage_inbound_phone_calls
            manage_call_data_records
            manage_phone_call_events
            manage_aws_sns_messages
          ],
          null: false

  alias_attribute :sid, :id

  include AASM

  aasm column: :status do
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

  def build_usage_record_collection(params = {})
    Usage::Record::Collection.new(params.merge("account" => self))
  end
end

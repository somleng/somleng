class Message < ApplicationRecord
  include AASM
  include HasBeneficiary
  extend Enumerize

  after_create :set_status_timestamp

  belongs_to :carrier
  belongs_to :account
  belongs_to :sms_gateway, optional: true
  belongs_to :phone_number, optional: true
  belongs_to :messaging_service, optional: true
  has_one :interaction
  has_many :events

  enumerize :direction, in: %i[inbound outbound outbound_api outbound_call outbound_reply],
                        predicates: true, scope: :shallow

  enumerize :encoding, in: %w[GSM UCS2]

  delegate :fire!, to: :aasm

  aasm column: :status, timestamps: true do
    state :accepted
    state :queued
    state :sending
    state :sent
    state :failed
    state :delivered
    state :received
    state :canceled
    state :scheduled

    event :queue do
      transitions from: %i[accepted scheduled], to: :queued
    end

    event :mark_as_sending do
      transitions from: :queued, to: :sending
    end

    event :mark_as_sent do
      transitions from: :sending, to: :sent
    end

    event :mark_as_delivered do
      transitions from: %i[sending sent], to: :delivered
    end

    event :mark_as_failed do
      transitions from: %i[accepted queued sending sent], to: :failed
    end

    event :cancel do
      transitions from: :scheduled, to: :canceled
    end
  end

  def self.default_scope
    where(internal: false)
  end

  def outbound?
    direction.in?(%w[outbound_api outbound outbound_call outbound_reply])
  end

  def complete?
    status.in?(%w[sent failed received])
  end

  def validity_period_expired?
    return false if validity_period.blank?

    (queued_at + validity_period.seconds).past?
  end

  private

  def set_status_timestamp
    timestamp_column = "#{status}_at"
    return if public_send(timestamp_column).present?

    public_send("#{timestamp_column}=", Time.current)
  end
end

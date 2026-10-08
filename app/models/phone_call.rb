class PhoneCall < ApplicationRecord
  extend Enumerize
  include AASM

  before_create :set_beneficiary_data

  attribute :beneficiary_fingerprint, SHA256Type.new
  attribute :to, PhoneNumberType.new
  attribute :from, PhoneNumberType.new
  attribute :region, RegionType.new

  enumerize :voice_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]
  enumerize :recording_status_callback_method, in: %w[POST GET]
  enumerize :direction, in: %i[inbound outbound_api outbound_dial], predicates: true, scope: :shallow

  belongs_to :carrier
  belongs_to :account
  belongs_to :incoming_phone_number, optional: true
  belongs_to :phone_number, optional: true
  belongs_to :incoming_phone_number, optional: true
  belongs_to :sip_trunk, optional: true
  belongs_to :parent_call, optional: true, class_name: "PhoneCall"

  has_one    :call_data_record
  has_one    :interaction
  has_one    :balance_transaction
  has_many   :events
  has_many   :phone_call_events
  has_many   :recordings
  has_many   :tts_events
  has_many   :media_streams

  delegate :may_fire_event?, to: :aasm
  delegate :default_tts_voice, to: :account

  aasm column: :status do
    state :queued, initial: true
    state :initiating
    state :initiated
    state :ringing
    state :answered
    state :busy
    state :failed
    state :not_answered
    state :completed
    state :canceled
    state :session_timeout

    event :mark_as_initiating do
      transitions from: %i[queued initiating], to: :initiating
    end

    event :mark_as_initiated do
      transitions from: %i[queued initiating], to: :initiated, guard: :external_id?
    end

    event :cancel do
      transitions from: %i[queued initiating initiated ringing], to: :canceled
    end

    event :ring do
      transitions from: :initiated, to: :ringing
    end

    event :answer do
      transitions from: %i[initiated ringing], to: :answered
    end

    event :complete do
      transitions from: %i[initiated ringing answered], to: :completed
    end

    event :mark_as_not_answered do
      transitions from: %i[initiated ringing], to: :not_answered
    end

    event :mark_as_busy do
      transitions from: %i[initiated ringing], to: :busy
    end

    event :fail do
      transitions from: %i[initiated ringing], to: :failed
    end
  end

  validates :external_id, presence: true, if: :inbound?

  def self.in_progress
    where(status: %w[initiated ringing answered])
  end

  def self.in_progress_or_initiating
    where(status: %w[initiating initiated ringing answered])
  end

  def was_initiated?
    initiated_at.present?
  end

  def uncompleted?
    status.in?([ "queued", "initiating", "initiated", "ringing", "answered" ])
  end

  def user_terminated?
    user_terminated_at.present?
  end

  def outbound?
    outbound_api? || outbound_dial?
  end

  def price
    InfinitePrecisionMoney.new(price_cents, price_unit) if price_cents.present?
  end

  def tariff_schedule_category
    TariffScheduleCategoryType.new.cast(outbound? ? :outbound_calls : :inbound_calls)
  end

  private

  def set_beneficiary_data
    beneficiary_number = outbound? ? to : from

    return unless beneficiary_number.e164?

    self.beneficiary_fingerprint = beneficiary_number.value
    self.beneficiary_country_code = ResolvePhoneNumberCountry.call(
      beneficiary_number,
      fallback_country: sip_trunk&.inbound_country || carrier.country
    ).alpha2
  end
end

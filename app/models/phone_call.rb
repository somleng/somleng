class PhoneCall < ApplicationRecord
  extend Enumerize
  include AASM

  enumerize :voice_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]
  enumerize :recording_status_callback_method, in: %w[POST GET]
  enumerize :direction, in: %i[inbound outbound], predicates: true, scope: :shallow

  attribute :beneficiary_fingerprint, SHA256Type.new

  belongs_to :carrier
  belongs_to :account
  belongs_to :phone_number, optional: true
  belongs_to :inbound_sip_trunk, optional: true
  belongs_to :outbound_sip_trunk, optional: true

  has_one    :call_data_record, -> { where(call_leg: :A) }
  has_one    :interaction, as: :interactable
  has_many   :phone_call_events
  has_many   :recordings

  delegate :may_fire_event?, to: :aasm

  aasm column: :status do
    state :queued, initial: true
    state :initiated
    state :ringing
    state :answered
    state :busy
    state :failed
    state :not_answered
    state :completed
    state :canceled

    event :initiate do
      transitions from: :queued, to: :initiated, guard: :external_id?
    end

    event :cancel do
      transitions from: %i[queued initiated ringing], to: :canceled
    end

    event :ring do
      transitions from: :initiated, to: :ringing
    end

    event :answer do
      transitions from: %i[initiated ringing], to: :answered
    end

    event :complete do
      transitions from: %i[initiated ringing answered completed], to: :completed
    end

    event :mark_as_not_answered do
      transitions from: %i[initiated ringing not_answered], to: :not_answered
    end

    event :mark_as_busy do
      transitions from: %i[initiated ringing busy], to: :busy
    end

    event :fail do
      transitions from: %i[initiated ringing failed], to: :failed
    end
  end

  validates :external_id, presence: true, if: :inbound?
  before_create :normalize_phone_numbers
  before_create :set_beneficiary_data

  def fire_event!(event)
    aasm.fire!(event)
  end

  private

  def normalize_phone_numbers
    self.from = Phony.normalize(from)
    self.to = Phony.normalize(to)
  end

  def set_beneficiary_data
    self.beneficiary_fingerprint = beneficiary
    self.beneficiary_country_code = ResolvePhoneNumberCountry.call(
      beneficiary,
      fallback_country: carrier.country
    ).alpha2
  end

  def beneficiary
    outbound? ? to : from
  end
end

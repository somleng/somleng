class Verification < ApplicationRecord
  class DefaultTemplate
    attr_reader :friendly_name, :code

    def initialize(friendly_name:, code:)
      @friendly_name = friendly_name
      @code = code
    end

    def render
      "Your #{friendly_name} verification code is: #{code}."
    end
  end

  include AASM
  extend Enumerize

  MAX_CHECK_ATTEMPTS = 5
  MAX_DELIVERY_ATTEMPTS = 5

  belongs_to :carrier
  belongs_to :account
  belongs_to :verification_service

  has_many :verification_attempts
  has_many :delivery_attempts, class_name: "VerificationDeliveryAttempt"

  enumerize :channel, in: %i[sms call]
  encrypts :code

  delegate :may_fire_event?, :fire!, to: :aasm
  delegate :code_length, to: :verification_service

  before_create :generate_code, :set_expiry

  aasm column: :status, timestamps: true do
    state :pending, initial: true
    state :approved
    state :canceled

    event :approve do
      transitions from: :pending, to: :approved
    end

    event :cancel do
      transitions from: :pending, to: :canceled
    end
  end

  def self.pending
    where(
      status: :pending,
      expired_at: Time.current..
    )
  end

  def expired?
    expired_at.past?
  end

  def max_check_attempts_reached?
    verification_attempts_count >= MAX_CHECK_ATTEMPTS
  end

  def max_delivery_attempts_reached?
    delivery_attempts_count >= MAX_DELIVERY_ATTEMPTS
  end

  def default_template
    DefaultTemplate.new(friendly_name: verification_service.name, code:)
  end

  private

  def generate_code
    self.code ||= SecureRandom.random_number(10**code_length).to_s.rjust(code_length, "0")
  end

  def set_expiry
    self.expired_at ||= 10.minutes.from_now
  end
end

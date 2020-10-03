class PhoneCall < ApplicationRecord
  extend Enumerize
  include AASM

  enumerize :voice_method, in: %w[POST GET]
  enumerize :status_callback_method, in: %w[POST GET]
  enumerize :direction, in: %i[inbound outbound], predicates: true

  belongs_to :account
  belongs_to :incoming_phone_number, optional: true

  has_one    :call_data_record
  has_many   :phone_call_events

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
      transitions from: :queued, to: :canceled
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
  before_save :normalize_phone_numbers

  private

  def normalize_phone_numbers
    self.from = Phony.normalize(from)
    self.to = Phony.normalize(to)
  end
end

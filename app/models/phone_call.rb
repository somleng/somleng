class PhoneCall < ApplicationRecord
  include Wisper::Publisher

  belongs_to :account
  belongs_to :incoming_phone_number, optional: true
  belongs_to :recording, optional: true

  has_one    :call_data_record
  has_many   :phone_call_events, class_name: "PhoneCallEvent::Base"
  has_many   :recordings

  validates :from, :to, presence: true
  validates :external_id, uniqueness: true, strict: true, allow_nil: true

  attr_accessor :completed_event, :twilio_request_to

  delegate :answered?, :not_answered?, :busy?,
           to: :completed_event,
           prefix: true,
           allow_nil: true

  include AASM

  aasm column: :status, whiny_transitions: false do
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
      transitions from: :queued, to: :canceled
    end

    event :ring do
      transitions from: :initiated, to: :ringing
    end

    event :answer do
      transitions from: %i[initiated ringing], to: :answered
    end

    event :complete, after_commit: :publish_completed do
      transitions from: :answered,
                  to: :completed

      transitions from: %i[initiated ringing],
                  to: :completed,
                  if: :phone_call_event_answered?

      transitions from: %i[initiated ringing],
                  to: :not_answered,
                  if: :phone_call_event_not_answered?

      transitions from: %i[initiated ringing],
                  to: :busy,
                  if: :phone_call_event_busy?

      transitions from: %i[initiated ringing],
                  to: :failed
    end
  end

  def self.find_by_uuid!(uuid)
    where(id: uuid).or(where(external_id: uuid)).first!
  end

  private

  def publish_completed
    broadcast(:phone_call_completed, self)
  end

  def phone_call_event_answered?
    completed_event&.answered? || call_data_record&.answered?
  end

  def phone_call_event_not_answered?
    completed_event&.not_answered? || call_data_record&.not_answered?
  end

  def phone_call_event_busy?
    completed_event&.busy? || call_data_record&.busy?
  end
end

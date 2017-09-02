class Recording < ApplicationRecord
  belongs_to :phone_call
  has_many :phone_call_events,      :class_name => "PhoneCallEvent::Base"
  has_many :aws_sns_notifications,  :class_name => "AwsSnsMessage::Notification"
  has_one  :currently_recording_phone_call, :class_name => "PhoneCall"

  validates :status, :presence => true
  validates :original_file_id, :uniqueness => true

  attachment :file, :content_type => ["audio/wav", "audio/x-wav"]

  include AASM

  aasm :column => :status, :whiny_transitions => false do
    state :initiated, :initial => true
    state :waiting_for_file
    state :failed
    state :processing
    state :completed

    event :wait_for_file do
      transitions :from => :initiated, :to => :waiting_for_file, :guard => :original_file_id?
      transitions :from => :initiated, :to => :failed
    end

    event :process do
      transitions :from => :waiting_for_file, :to => :processing
    end

    event :complete do
      transitions :from => :processing, :to => :completed
    end
  end
end

class MediaStream < ApplicationRecord
  include AASM
  extend Enumerize

  enumerize :tracks, in: %i[inbound outbound both]

  belongs_to :account
  belongs_to :phone_call
  has_many :events, class_name: "MediaStreamEvent"

  aasm column: :status, whiny_transitions: false do
    state :initialized, initial: true
    state :connect_failed
    state :connected
    state :started
    state :disconnected

    event :connect do
      transitions from: :initialized, to: :connected
    end

    event :start do
      transitions from: [ :initialized, :connected ], to: :started
    end

    event :fail_to_connect do
      transitions from: [ :initialized ], to: :connect_failed
    end

    event :disconnect do
      transitions from: [ :connected, :started ], to: :disconnected
    end
  end
end

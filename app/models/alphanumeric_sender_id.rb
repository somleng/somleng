class AlphanumericSenderID < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  belongs_to :account
  has_many :messages
  has_many :messaging_service_alphanumeric_sender_ids, foreign_key: :sender_id_id
  has_many :messaging_services, through: :messaging_service_alphanumeric_sender_ids

  validates :sender_id, presence: true,
            alphanumeric_sender_id_format: true,
            uniqueness: {
              scope: :carrier_id,
              case_sensitive: false,
              conditions: -> { approved },
              if: :approved?
            }

  class StateMachine < ::StateMachine::ActiveRecord
    state :pending_approval, initial: true, transitions_to: [ :approved, :rejected ]
    state :approved, transitions_to: :revoked, guard: ->(record) { }
    state :rejected
    state :revoked
  end

  enumerize :status,
            in: StateMachine.state_definitions.map(&:name),
            default: StateMachine.state_definitions.find { it.initial }.name,
            predicates: true,
            scope: :shallow

  delegate :may_transition_to?, :transition_to, :transition_to!, to: :state_machine

  def state_machine
    @state_machine ||= StateMachine.new(self)
  end
end

class AlphanumericSenderID < ApplicationRecord
  extend Enumerize

  belongs_to :carrier
  belongs_to :account

  validates :sender_id, presence: true, alphanumeric_sender_id_format: true

  class StateMachine < ::StateMachine::ActiveRecord
    state :pending_approval, initial: true, transitions_to: [ :approved, :rejected ]
    state :approved, transitions_to: :revoked
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

require "rails_helper"

module StateMachine
  RSpec.describe Machine do
    it "handles state transitions" do
      state_machine_definition = Class.new(Machine) do
        state :pending, initial: true, transitions_to: :queued
        state :queued, transitions_to: [ :running, :errored ]
        state :errored, transitions_to: { running: { as: :queued } }
        state :running, transitions_to: [ :stopped, :completed ]
        state :stopped, transitions_to: :running
        state :completed
      end

      state_machine = state_machine_definition.new

      expect(state_machine.pending?).to be(true)
      expect(state_machine.may_transition_to?(:queued)).to be(true)
      expect(state_machine.may_transition_to?(:stopped)).to be(false)

      state_machine.transition_to(:queued)

      expect(state_machine.queued?).to be(true)

      state_machine.transition_to(:pending)

      expect(state_machine.pending?).to be(false)
      expect(state_machine.queued?).to be(true)

      state_machine.transition_to!(:errored)

      expect(state_machine.errored?).to be(true)

      state_machine.transition_to!(:running)

      expect(state_machine.queued?).to be(true)
      expect(state_machine.running?).to be(false)

      state_machine.transition_to!(:running)

      expect(state_machine.running?).to be(true)

      expect { state_machine.transition_to!(:pending) }.to raise_error(Machine::InvalidStateTransitionError)

      expect(state_machine.pending?).to be(false)
      expect(state_machine.running?).to be(true)
    end
  end
end

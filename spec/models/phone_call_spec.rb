require "rails_helper"

RSpec.describe PhoneCall do
  describe "associations" do
    it { is_expected.to belong_to(:incoming_phone_number).optional }
    it { is_expected.to belong_to(:recording).optional }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:from) }
    it { is_expected.to validate_presence_of(:to) }
    it { expect(create(:phone_call)).to validate_uniqueness_of(:external_id).allow_nil.strict }
  end

  describe "state machine" do
    it "transitions to the correct state" do
      any_call = build_stubbed(:phone_call)
      queued_call = build_stubbed(:phone_call, external_id: generate(:external_id))
      answered_call = build_phone_call_with_completed_event(:answered)
      not_answered_call = build_phone_call_with_completed_event(:not_answered)
      busy_call = build_phone_call_with_completed_event(:busy)
      answered_call_with_cdr = build_phone_call_with_cdr(:event_answered)
      not_answered_call_with_cdr = build_phone_call_with_cdr(:event_not_answered)
      busy_call_with_cdr = build_phone_call_with_cdr(:event_busy)

      expect(any_call).to transition_from(:queued).to(:canceled).on_event(:initiate)
      expect(any_call).to transition_from(:initiated).to(:ringing).on_event(:ring)
      expect(any_call).to transition_from(:initiated).to(:answered).on_event(:answer)
      expect(any_call).to transition_from(:ringing).to(:answered).on_event(:answer)
      expect(any_call).to transition_from(:answered).to(:completed).on_event(:complete)
      expect(any_call).to transition_from(:initiated).to(:failed).on_event(:complete)
      expect(any_call).to transition_from(:ringing).to(:failed).on_event(:complete)
      expect(queued_call).to transition_from(:queued).to(:initiated).on_event(:initiate)
      expect(answered_call).to transition_from(:initiated).to(:completed).on_event(:complete)
      expect(answered_call).to transition_from(:ringing).to(:completed).on_event(:complete)
      expect(not_answered_call).to transition_from(:initiated).to(:not_answered).on_event(:complete)
      expect(not_answered_call).to transition_from(:ringing).to(:not_answered).on_event(:complete)
      expect(busy_call).to transition_from(:initiated).to(:busy).on_event(:complete)
      expect(busy_call).to transition_from(:ringing).to(:busy).on_event(:complete)
      expect(answered_call_with_cdr).to transition_from(:initiated).to(:completed).on_event(:complete)
      expect(answered_call_with_cdr).to transition_from(:ringing).to(:completed).on_event(:complete)
      expect(not_answered_call_with_cdr).to transition_from(:initiated).to(:not_answered).on_event(:complete)
      expect(not_answered_call_with_cdr).to transition_from(:ringing).to(:not_answered).on_event(:complete)
      expect(busy_call_with_cdr).to transition_from(:initiated).to(:busy).on_event(:complete)
      expect(busy_call_with_cdr).to transition_from(:ringing).to(:busy).on_event(:complete)
    end
  end

  def build_phone_call_with_completed_event(*event_traits)
    event = build_stubbed(:phone_call_event, *event_traits)
    build_stubbed(:phone_call, completed_event: event)
  end

  def build_phone_call_with_cdr(*cdr_traits)
    phone_call = build_stubbed(:phone_call)
    build_stubbed(:call_data_record, *cdr_traits, phone_call: phone_call)
    phone_call
  end
end

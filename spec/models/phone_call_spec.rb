# frozen_string_literal: true

require "rails_helper"

describe PhoneCall do
  let(:factory) { :phone_call }

  it_behaves_like "phone_number_attribute" do
    let(:phone_number_attribute) { :to }
  end

  describe "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:incoming_phone_number).optional }
    it { is_expected.to belong_to(:recording).optional }
    it { is_expected.to have_one(:call_data_record) }
    it { is_expected.to have_many(:phone_call_events) }
    it { is_expected.to have_many(:recordings) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:from) }

    context "persisted" do
      subject { create(factory) }

      context "#external_id" do
        it { is_expected.to validate_uniqueness_of(:external_id).allow_nil.strict }
      end

      it { is_expected.to allow_value("855970001294").for(:to) }
    end

    context "for outbound calls" do
      it { is_expected.not_to allow_value("855970001294").for(:to) }
    end

    context "for inbound calls" do
      subject { build(factory, :initiating_inbound_call) }

      it { is_expected.to allow_value("855970001294").for(:to) }
      it { is_expected.to validate_presence_of(:external_id) }
      it { is_expected.to validate_presence_of(:incoming_phone_number) }
    end
  end

  describe "state_machine" do
    def subject_traits
      { current_status_trait => nil }
    end

    def subject_attributes
      {}
    end

    subject { create(factory, *subject_traits.keys, subject_attributes) }

    context "state is 'queued'" do
      let(:current_status_trait) { :queued }

      context "external_id is not present" do
        def assert_transitions!
          expect(subject).to transition_from(:queued).to(:canceled).on_event(:cancel)
        end

        it { assert_transitions! }
      end

      context "external_id is present" do
        def subject_traits
          super.merge(with_external_id: nil)
        end

        def assert_transitions!
          expect(subject).to transition_from(:queued).to(:initiated).on_event(:initiate)
        end

        it { assert_transitions! }
      end
    end

    context "state is 'initiated'" do
      let(:current_status_trait) { :initiated }

      def assert_transitions!
        expect(subject).to transition_from(:initiated).to(:ringing).on_event(:ring)
        expect(subject).to transition_from(:initiated).to(:answered).on_event(:answer)
      end

      it { assert_transitions! }
    end

    context "state is 'ringing'" do
      let(:current_status_trait) { :ringing }

      def assert_transitions!
        expect(subject).to transition_from(:ringing).to(:answered).on_event(:answer)
      end

      it { assert_transitions! }
    end

    context "state is 'answered'" do
      let(:current_status_trait) { :answered }

      def assert_transitions!
        expect(subject).to transition_from(:answered).to(:completed).on_event(:complete)
      end

      it { assert_transitions! }
    end

    describe "#complete" do
      let(:event) { :complete }

      context "can complete" do
        subject { create(factory, :can_complete) }

        it("broadcasts") {
          assert_broadcasted!(:phone_call_completed) { subject.complete! }
        }
      end

      context "already completed" do
        subject { create(factory, :already_completed) }

        it("does not broadcast") {
          assert_not_broadcasted!(:phone_call_completed) { subject.complete! }
        }
      end

      def assert_transitions!
        expect(subject).to transition_from(subject.status).to(asserted_next_status).on_event(event)
      end

      context "with completed_event" do
        let(:phone_call_event) { build(:phone_call_event_completed, *phone_call_event_traits.keys) }

        def phone_call_event_traits
          {
            phone_call_event_trait => nil
          }
        end

        def subject_attributes
          super.merge(completed_event: phone_call_event)
        end

        # phone_call_event_trait => asserted status
        asserted_state_transitions = {
          not_answered: :not_answered,
          busy: :busy,
          answered: :completed,
          failed: :failed
        }

        %i[initiated ringing].each do |current_status_trait|
          asserted_state_transitions.each do |phone_call_event_trait, asserted_next_status|
            context "self.status => '#{current_status_trait}', self.event_#{phone_call_event_trait}? => true" do
              let(:phone_call_event_trait) { phone_call_event_trait }
              let(:current_status_trait) { current_status_trait }
              let(:asserted_next_status) { asserted_next_status }

              it { assert_transitions! }
            end
          end
        end
      end

      %i[not_answered busy failed completed].each do |current_status_trait|
        context "self.status => '#{current_status_trait}'" do
          let(:current_status_trait) { current_status_trait }
          let(:asserted_next_status) { subject.status }

          def assert_transitions!
            expect(subject).not_to transition_from(current_status_trait).to(asserted_next_status).on_event(event)
          end

          it { assert_transitions! }
        end
      end
    end
  end

  describe "#initate_or_cancel!" do
    before do
      subject.initiate_or_cancel!
    end

    context "given there's a external_id" do
      subject { create(factory, :queued, :with_external_id) }

      it { is_expected.to be_initiated }
    end

    context "given there is no external_id" do
      subject { create(factory, :queued) }

      it { is_expected.to be_canceled }
    end
  end

  describe "#initiate_inbound_call" do
    subject { build(factory, from: from, to: phone_number, external_id: external_id) }

    let(:phone_number) { generate(:phone_number) }
    let(:external_id) { generate(:external_id) }
    let(:from) { "+0973234567" }

    def setup_scenario; end

    before do
      setup_scenario
      subject.initiate_inbound_call
    end

    context "given no matching incoming phone number" do
      def assert_errors!
        expect(subject).not_to be_persisted
        expect(subject.errors).not_to be_empty
      end

      it { assert_errors! }
    end

    context "given an matching incoming phone number" do
      let(:twilio_incoming_phone_number) { "12345678" }
      let(:incoming_phone_number) do
        create(
          :incoming_phone_number,
          :with_twilio_request_phone_number,
          phone_number: phone_number
        )
      end

      def setup_scenario
        super
        incoming_phone_number
      end

      def assert_created!
        expect(subject).to be_persisted
        expect(subject.voice_url).to eq(incoming_phone_number.voice_url)
        expect(subject.voice_method).to eq(incoming_phone_number.voice_method)
        expect(subject.status_callback_url).to eq(incoming_phone_number.status_callback_url)
        expect(subject.status_callback_method).to eq(incoming_phone_number.status_callback_method)
        expect(subject.external_id).to eq(external_id)
        expect(subject.account).to eq(incoming_phone_number.account)
        expect(subject.incoming_phone_number).to eq(incoming_phone_number)
        expect(subject.twilio_request_to).to eq(incoming_phone_number.twilio_request_phone_number)
        expect(subject.from).to eq(from)
        expect(subject).to be_initiated
      end

      context "standard incoming phone number" do
        it { assert_created! }
      end

      context "non-standard incoming phone number (https://github.com/dwilkie/twilreapi/issues/17)" do
        let(:phone_number) { "+855970001294" }

        it { assert_created! }
      end
    end
  end
end

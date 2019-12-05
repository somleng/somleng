# frozen_string_literal: true

require "rails_helper"

describe PhoneCall do
  let(:factory) { :phone_call }

  it_behaves_like "twilio_api_resource"
  it_behaves_like "twilio_url_logic"
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
    it { is_expected.not_to allow_value("855970001294").for(:to) }

    it "validates uniqueness of external id" do
      phone_call = create(:phone_call)
      expect(phone_call).to validate_uniqueness_of(:external_id).allow_nil.strict
    end

    it "allows invalid to for inbound calls" do
      incoming_phone_number = create(:incoming_phone_number)
      phone_call = build(:phone_call, incoming_phone_number: incoming_phone_number)

      expect(phone_call).to allow_value("855970001294").for(:to)
      expect(phone_call).to validate_presence_of(:external_id)
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

  describe "#to_json" do
    it "returns json" do
      phone_call = create(:phone_call, :not_answered)

      json = JSON.parse(phone_call.to_json)

      expect(json.keys).to include(
        "parent_call_sid", "to", "to_formatted",
        "from", "from_formatted", "phone_number_sid",
        "status", "start_time", "end_time",
        "duration", "price", "price_unit",
        "direction", "answered_by", "annotation",
        "forwarded_from", "group_sid", "caller_name",
        "subresource_uris"
      )

      expect(json.fetch("status")).to eq("no-answer")
    end
  end

  describe "#to_internal_outbound_call_json" do
    it "returns json for an outbound call" do
      phone_call = create(:phone_call, :with_optional_attributes)

      json = JSON.parse(phone_call.to_internal_outbound_call_json)

      expect(json.keys).to match_array(
        %w[
          sid account_sid account_auth_token voice_url
          voice_method from to routing_instructions
          api_version direction
        ]
      )
    end
  end

  describe "#to_internal_inbound_call_json" do
    it "returns json for an inbound call" do
      phone_call = create(:phone_call, :inbound)

      json = JSON.parse(phone_call.to_internal_inbound_call_json)

      expect(json.keys).to match_array(
        %w[
          sid account_sid account_auth_token
          voice_url voice_method from to twilio_request_to
          api_version direction
        ]
      )
    end
  end

  describe "#twilio_status" do
    asserted_twilio_call_status_mappings = {
      queued: "queued",
      initiated: "queued",
      ringing: "ringing",
      answered: "in-progress",
      busy: "busy",
      failed: "failed",
      not_answered: "no-answer",
      completed: "completed",
      canceled: "canceled"
    }

    let(:result) { subject.twilio_status }

    asserted_twilio_call_status_mappings.each do |phone_call_trait, asserted_twilio_status|
      context "self.status => '#{phone_call_trait}'" do
        subject { build(factory, phone_call_trait) }

        it { expect(result).to eq(asserted_twilio_status) }
      end
    end
  end

  describe "#uri" do
    subject { create(factory) }

    it { expect(subject.uri).to eq("/api/2010-04-01/Accounts/#{subject.account_sid}/Calls/#{subject.sid}") }
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

  describe "#active_call_router" do
    it "returns the active call router with custom options" do
      phone_call = described_class.new

      result = phone_call.active_call_router

      expect(result).to be_a(CallRouter)
      expect(result.source).to eq(phone_call.from)
      expect(result.destination).to eq(phone_call.to)
    end
  end

  describe "#initiate_inbound_call" do
    it "is invalid when there is no matching incoming phone number" do
      phone_call = build(:phone_call, :inbound, from: "+0973234567")

      phone_call.initiate_inbound_call

      expect(phone_call).not_to be_persisted
      expect(phone_call.errors[:incoming_phone_number]).to be_present
    end

    it "creates a phone call if there's a matching incoming phone number" do
      account = create(:account, settings: { trunk_prefix_replacement: "855" })
      incoming_phone_number = create(:incoming_phone_number, account: account, phone_number: "1294")
      phone_call = build(:phone_call, :inbound, from: "+0973234567", to: "1294")

      phone_call.initiate_inbound_call

      expect(phone_call).to have_attributes(
        persisted?: true,
        initiated?: true,
        incoming_phone_number: incoming_phone_number,
        voice_url: incoming_phone_number.voice_url,
        voice_method: incoming_phone_number.voice_method,
        status_callback_url: incoming_phone_number.status_callback_url,
        status_callback_method: incoming_phone_number.status_callback_method,
        account: incoming_phone_number.account,
        to: "1294",
        from: "+855973234567"
      )
    end
  end

  describe "#enqueue_outbound_call!" do
    subject { create(factory) }

    let(:enqueued_job) { enqueued_jobs.first }

    before do
      subject.enqueue_outbound_call!
    end

    def assert_enqueued!
      expect(enqueued_job[:args]).to match_array([subject.id])
    end

    it { assert_enqueued! }
  end

  describe "#annotation" do
    # deprecated
    it { expect(subject.annotation).to eq(nil) }
  end

  describe "#answered_by" do
    it { expect(subject.answered_by).to eq(nil) }
  end

  describe "#caller_name" do
    it { expect(subject.caller_name).to eq(nil) }
  end

  describe "#direction" do
    it "uses the direction of the CDR for inbound calls" do
      call_data_record = create(:call_data_record, :inbound)
      phone_call = create(:phone_call, call_data_record: call_data_record)

      expect(phone_call.direction).to eq("inbound")
    end

    it "uses the direction of the CDR for outbound calls" do
      call_data_record = create(:call_data_record, :outbound)
      phone_call = create(:phone_call, call_data_record: call_data_record)

      expect(phone_call.direction).to eq("outbound-api")
    end

    it "implies the direction for inbound calls" do
      incoming_phone_number = create(:incoming_phone_number)
      phone_call = create(:phone_call, :inbound, incoming_phone_number: incoming_phone_number)

      expect(phone_call.direction).to eq("inbound")
    end

    it "implies the direction for outbound calls" do
      expect(create(:phone_call).direction).to eq("outbound-api")
    end
  end

  describe "#duration" do
    context "with cdr" do
      subject { create(factory, call_data_record: call_data_record) }

      let(:bill_sec) { "15" }
      let(:call_data_record) { build(:call_data_record, bill_sec: bill_sec) }

      it { expect(subject.duration).to eq(bill_sec) }
    end

    context "without cdr" do
      it { expect(subject.duration).to eq(nil) }
    end
  end

  describe "#end_time" do
    it { expect(create(:phone_call).end_time).to eq(nil) }

    it "returns the value from the CDR" do
      call_data_record = create(
        :call_data_record,
        end_time: Time.utc("2015", "9", "30", "23", "05", "12"),
      )
      phone_call = create(:phone_call, call_data_record: call_data_record)

      expect(phone_call.end_time).to eq("Wed, 30 Sep 2015 23:05:12 +0000")
    end
  end

  describe "#forwarded_from" do
    it { expect(subject.forwarded_from).to eq(nil) }
  end

  describe "#from_formatted" do
    subject { create(factory, from: from) }

    context "international formatted number" do
      let(:from) { "85512345678" }

      it { expect(subject.from_formatted).to eq("+855 12 345 678") }
    end

    context "non-standard number (https://github.com/dwilkie/twilreapi/issues/25)" do
      let(:from) { "+0887883050" }

      it { expect(subject.from_formatted).to eq(from) }
    end
  end

  describe "#group_sid" do
    # deprecated
    it { expect(subject.group_sid).to eq(nil) }
  end

  describe "#parent_call_sid" do
    it { expect(subject.parent_call_sid).to eq(nil) }
  end

  describe "#phone_number_sid" do
    it "returns a value inbound calls" do
      incoming_phone_number = create(:incoming_phone_number)
      phone_call = create(:phone_call, :inbound, incoming_phone_number: incoming_phone_number)
      expect(phone_call.phone_number_sid).to eq(incoming_phone_number.id)
    end

    it "returns nil for outbound calls" do
      expect(create(:phone_call).phone_number_sid).to eq(nil)
    end
  end

  describe "#price" do
    it { expect(subject.price).to eq(nil) }
  end

  describe "#price_unit" do
    # deprecated
    it { expect(subject.price_unit).to eq(nil) }
  end

  describe "#start_time" do
    context "with cdr" do
      subject { create(factory, call_data_record: call_data_record) }

      let(:call_data_record) { build(:call_data_record, answer_time: answer_time) }

      context "call not answered" do
        let(:answer_time) { nil }

        it { expect(subject.start_time).to eq(nil) }
      end

      context "call answered" do
        let(:answer_time) { Time.utc("2015", "9", "30", "23", "05", "12") }

        it { expect(subject.start_time).to eq("Wed, 30 Sep 2015 23:05:12 +0000") }
      end
    end

    context "without cdr" do
      it { expect(subject.start_time).to eq(nil) }
    end
  end

  describe "#subresource_uris" do
    # From: https://www.twilio.com/docs/api/rest/response#hypermedia-in-instance-resources

    subject { create(factory) }

    let(:result) { subject.subresource_uris }

    def setup_scenario; end

    before do
      setup_scenario
    end

    context "given the phone call has recordings" do
      let(:recording) { create(:recording, phone_call: subject) }

      def setup_scenario
        recording
      end

      def assert_result!
        expect(result).to include("recordings" => Rails.application.routes.url_helpers.api_twilio_account_call_recordings_path(subject.account_id, subject.id))
      end

      it { assert_result! }
    end

    context "given the phone call has no recordings" do
      it { expect(result).to eq({}) }
    end
  end

  describe "#to_formatted" do
    subject { create(factory, to: to) }

    context "international formatted number" do
      let(:to) { "85510987654" }

      it { expect(subject.to_formatted).to eq("+855 10 987 654") }
    end
  end
end

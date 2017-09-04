require 'rails_helper'

describe PhoneCall do
  let(:factory) { :phone_call }

  it_behaves_like "twilio_api_resource"
  it_behaves_like "twilio_url_logic"
  it_behaves_like "phone_number_attribute" do
    let(:phone_number_attribute) { :to }
  end

  describe "associations" do
    it { is_expected.to belong_to(:account) }
    it { is_expected.to belong_to(:incoming_phone_number) }
    it { is_expected.to belong_to(:recording) }
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
      {current_status_trait => nil}
    end

    def subject_attributes
      {}
    end

    subject { create(factory, *subject_traits.keys, subject_attributes) }

    context "state is 'queued'" do
      let(:current_status_trait) { :queued }

      context "external_id is not present" do
        def assert_transitions!
          is_expected.to transition_from(:queued).to(:canceled).on_event(:cancel)
        end

        it { assert_transitions! }
      end

      context "external_id is present" do
        def subject_traits
          super.merge(:with_external_id => nil)
        end

        def assert_transitions!
          is_expected.to transition_from(:queued).to(:initiated).on_event(:initiate)
        end

        it { assert_transitions! }
      end
    end

    context "state is 'initiated'" do
      let(:current_status_trait) { :initiated }

      def assert_transitions!
        is_expected.to transition_from(:initiated).to(:ringing).on_event(:ring)
        is_expected.to transition_from(:initiated).to(:answered).on_event(:answer)
      end

      it { assert_transitions! }
    end

    context "state is 'ringing'" do
      let(:current_status_trait) { :ringing }

      def assert_transitions!
        is_expected.to transition_from(:ringing).to(:answered).on_event(:answer)
      end

      it { assert_transitions! }
    end

    context "state is 'answered'" do
      let(:current_status_trait) { :answered }

      def assert_transitions!
        is_expected.to transition_from(:answered).to(:completed).on_event(:complete)
      end

      it { assert_transitions! }
    end

    describe "#complete" do
      let(:event) { :complete }

      context "can complete" do
        subject { create(factory, :can_complete) }
        it("should broadcast") {
          assert_broadcasted!(:phone_call_completed) { subject.complete! }
        }
      end

      context "already completed" do
        subject { create(factory, :already_completed) }
        it("should not broadcast") {
          assert_not_broadcasted!(:phone_call_completed) { subject.complete! }
        }
      end

      def assert_transitions!
        is_expected.to transition_from(subject.status).to(asserted_next_status).on_event(event)
      end

      context "with completed_event" do
        let(:phone_call_event) { build(:phone_call_event_completed, *phone_call_event_traits.keys) }

        def phone_call_event_traits
          {
            phone_call_event_trait => nil
          }
        end

        def subject_attributes
          super.merge(:completed_event => phone_call_event)
        end

        # phone_call_event_trait => asserted status
        asserted_state_transitions = {
          :not_answered => :not_answered,
          :busy => :busy,
          :answered => :completed,
          :failed => :failed
        }

        [:initiated, :ringing].each do |current_status_trait|
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

      [:not_answered, :busy, :failed, :completed].each do |current_status_trait|
        context "self.status => '#{current_status_trait}'" do
          let(:current_status_trait) { current_status_trait }
          let(:asserted_next_status) { subject.status }

          def assert_transitions!
            is_expected.not_to transition_from(current_status_trait).to(asserted_next_status).on_event(event)
          end

          it { assert_transitions! }
        end
      end
    end
  end

  describe "json" do
    let(:json) { JSON.parse(subject.public_send(json_method)) }

    describe "#to_json" do
      let(:json_method) { :to_json }
      subject { create(factory) }

      let(:twilio_json_keys) do
        ["parent_call_sid", "to", "to_formatted", "from", "from_formatted", "phone_number_sid", "status", "start_time", "end_time", "duration", "price", "price_unit", "direction", "answered_by", "annotation", "forwarded_from", "group_sid", "caller_name", "subresource_uris"]
      end

      def assert_valid_json!
        expect(json.keys).to include(*twilio_json_keys)
      end

      it { assert_valid_json! }

      context "status" do
        subject { create(factory, :not_answered) }

        def assert_valid_json!
          expect(json["status"]).to eq(subject.twilio_status)
        end

        it { assert_valid_json! }
      end
    end

    describe "#to_internal_outbound_call_json" do
      subject { create(factory, :with_optional_attributes) }
      let(:json_method) { :to_internal_outbound_call_json }

      def assert_valid_json!
        expect(json.keys).to match_array(["sid", "account_sid", "account_auth_token", "voice_url", "voice_method", "from", "to", "routing_instructions", "api_version", "direction"])
      end

      it { assert_valid_json! }
    end

    describe "#to_internal_inbound_call_json" do
      subject { create(factory, :initiating_inbound_call) }
      let(:json_method) { :to_internal_inbound_call_json }

      def assert_valid_json!
        expect(json.keys).to match_array(["sid", "account_sid", "account_auth_token", "voice_url", "voice_method", "from", "to", "twilio_request_to", "api_version", "direction"])
      end

      it { assert_valid_json! }
    end
  end

  describe "#twilio_status" do
    asserted_twilio_call_status_mappings = {
      :queued => "queued",
      :initiated => "queued",
      :ringing => "ringing",
      :answered => "in-progress",
      :busy => "busy",
      :failed => "failed",
      :not_answered => "no-answer",
      :completed => "completed",
      :canceled => "canceled"
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

  describe "#initiate_outbound_call!" do
    subject { create(factory, :queued) }
    let(:outbound_call_id) { generate(:external_id) }
    let(:outbound_call_job) { instance_double(Twilreapi::Worker::Job::OutboundCallJob, :perform => outbound_call_id) }

    def assert_call_initiated!
      allow(Twilreapi::Worker::Job::OutboundCallJob).to receive(:new).and_return(outbound_call_job)
      expect(outbound_call_job).to receive(:perform).with(subject.to_internal_outbound_call_json)
      subject.initiate_outbound_call!
      expect(subject.external_id).to eq(outbound_call_id)
      is_expected.to be_initiated
    end

    it { assert_call_initiated! }
  end

  describe "#initiate_inbound_call" do
    let(:phone_number) { generate(:phone_number) }
    let(:external_id) { generate(:external_id) }

    subject { build(factory, :to => phone_number, :external_id => external_id) }

    def setup_scenario
    end

    before do
      setup_scenario
      subject.initiate_inbound_call
    end

    context "given no matching incoming phone number" do
      def assert_errors!
        is_expected.not_to be_persisted
        expect(subject.errors).not_to be_empty
      end

      it { assert_errors! }
    end

    context "given an matching incoming phone number" do
      let(:twilio_incoming_phone_number) { "12345678" }
      let(:incoming_phone_number) {
        create(
          :incoming_phone_number,
          :with_twilio_request_phone_number,
          :phone_number => phone_number
        )
      }

      def setup_scenario
        super
        incoming_phone_number
      end

      def assert_created!
        is_expected.to be_persisted
        expect(subject.voice_url).to eq(incoming_phone_number.voice_url)
        expect(subject.voice_method).to eq(incoming_phone_number.voice_method)
        expect(subject.status_callback_url).to eq(incoming_phone_number.status_callback_url)
        expect(subject.status_callback_method).to eq(incoming_phone_number.status_callback_method)
        expect(subject.external_id).to eq(external_id)
        expect(subject.account).to eq(incoming_phone_number.account)
        expect(subject.incoming_phone_number).to eq(incoming_phone_number)
        expect(subject.twilio_request_to).to eq(incoming_phone_number.twilio_request_phone_number)
        is_expected.to be_initiated
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
    def assert_inbound!
      expect(subject.direction).to eq("inbound")
    end

    def assert_outbound!
      expect(subject.direction).to eq("outbound-api")
    end

    context "with cdr" do
      subject { create(factory, :call_data_record => call_data_record) }
      let(:call_data_record) { build(:call_data_record, direction) }

      before do
        call_data_record
      end

      context "inbound calls" do
        let(:direction) { :inbound }
        it { assert_inbound! }
      end

      context "for outbound calls" do
        let(:direction) { :outbound }
        it { assert_outbound! }
      end
    end

    context "without cdr" do
      context "for inbound calls" do
        subject { create(factory, :initiating_inbound_call) }
        it { assert_inbound! }
      end

      context "for outbound calls" do
        it { assert_outbound! }
      end
    end
  end

  describe "#duration" do
    context "with cdr" do
      let(:bill_sec) { "15" }
      let(:call_data_record) { build(:call_data_record, :bill_sec => bill_sec) }
      subject { create(factory, :call_data_record => call_data_record) }

      it { expect(subject.duration).to eq(bill_sec) }
    end

    context "without cdr" do
      it { expect(subject.duration).to eq(nil) }
    end
  end

  describe "#end_time" do
    context "with cdr" do
      let(:end_time) { Time.utc("2015", "9", "30", "23", "05", "12") }
      let(:call_data_record) { build(:call_data_record, :end_time => end_time, :answer_time => answer_time) }
      subject { create(factory, :call_data_record => call_data_record) }

      context "call not answered" do
        let(:answer_time) { nil }
        it { expect(subject.end_time).to eq(nil) }
      end

      context "call answered" do
        let(:answer_time) { Time.utc("2015", "9", "30", "23", "04", "12") }
        it { expect(subject.end_time).to eq("Wed, 30 Sep 2015 23:05:12 +0000") }
      end
    end

    context "without cdr" do
      it { expect(subject.end_time).to eq(nil) }
    end
  end

  describe "#forwarded_from" do
    it { expect(subject.forwarded_from).to eq(nil) }
  end

  describe "#from_formatted" do
    subject { create(factory, :from => from) }

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
    context "for inbound calls" do
      subject { create(factory, :initiating_inbound_call) }
      it { expect(subject.phone_number_sid).to eq(subject.incoming_phone_number_sid) }
    end

    context "for outbound calls" do
      it { expect(subject.phone_number_sid).to eq(nil) }
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
      let(:call_data_record) { build(:call_data_record, :answer_time => answer_time) }
      subject { create(factory, :call_data_record => call_data_record) }

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
    it { expect(subject.subresource_uris).to eq({}) }
  end

  describe "#to_formatted" do
    subject { create(factory, :to => to) }

    context "international formatted number" do
      let(:to) { "85510987654" }
      it { expect(subject.to_formatted).to eq("+855 10 987 654") }
    end
  end
end

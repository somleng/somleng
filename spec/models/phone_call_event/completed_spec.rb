require 'rails_helper'

describe PhoneCallEvent::Completed do
  let(:factory) { :phone_call_event_completed }
  let(:asserted_event_name) { :phone_call_event_completed }
  include_examples("phone_call_event")

  describe "#answered?" do
    let(:answer_epoch) { nil }
    let(:answer_time) { nil }

    subject { build(factory, :answer_epoch => answer_epoch, :answer_time => answer_time) }

    context "answer_epoch > 0" do
      let(:answer_epoch) { "1" }
      it { is_expected.to be_answered }
    end

    context "answer_time is present" do
      let(:answer_time) { Time.now }
      it { is_expected.to be_answered }
    end

    context "neither is present" do
      it { is_expected.not_to be_answered }
    end
  end

  context "sip_term_status" do
    subject { build(factory, :sip_term_status => sip_term_status) }

    describe "#not_answered?" do
      asserted_statuses = [
        "480", "487", "603"
      ]

      asserted_statuses.each do |sip_term_status|
        context "sip_term_status is '#{sip_term_status}'" do
          let(:sip_term_status) { sip_term_status }
          it { is_expected.to be_not_answered }
        end
      end
    end

    describe "#busy?" do
      asserted_statuses = [
        "486"
      ]

      asserted_statuses.each do |sip_term_status|
        context "sip_term_status is '#{sip_term_status}'" do
          let(:sip_term_status) { sip_term_status }
          it { is_expected.to be_busy }
        end
      end
    end
  end
end

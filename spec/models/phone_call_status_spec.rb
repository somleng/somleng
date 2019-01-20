require "rails_helper"

RSpec.describe PhoneCallStatus do
  describe "#answered?" do
    it "returns true if the call was answered" do
      expect(build_phone_call_status(answer_epoch: nil).answered?).to eq(false)
      expect(build_phone_call_status(answer_epoch: "0").answered?).to eq(false)
      expect(build_phone_call_status(answer_time: nil).answered?).to eq(false)
      expect(build_phone_call_status(answer_epoch: "1").answered?).to eq(true)
      expect(build_phone_call_status(answer_time: Time.now).answered?).to eq(true)
    end
  end

  describe "#not_answered?" do
    it "returns true if the call was not answered" do
      expect(build_phone_call_status(sip_term_status: nil).not_answered?).to eq(false)
      expect(build_phone_call_status(sip_term_status: "200").not_answered?).to eq(false)
      expect(build_phone_call_status(sip_term_status: "480").not_answered?).to eq(true)
      expect(build_phone_call_status(sip_term_status: "487").not_answered?).to eq(true)
      expect(build_phone_call_status(sip_term_status: "603").not_answered?).to eq(true)
    end
  end

  describe "#busy?" do
    it "returns true if the call was busy" do
      expect(build_phone_call_status(sip_term_status: nil).busy?).to eq(false)
      expect(build_phone_call_status(sip_term_status: "200").busy?).to eq(false)
      expect(build_phone_call_status(sip_term_status: "486").busy?).to eq(true)
    end
  end

  def build_phone_call_status(options = {})
    described_class.new(options.reverse_merge(answer_time: nil, sip_term_status: nil))
  end
end

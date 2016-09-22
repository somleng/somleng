require 'rails_helper'

describe CDR::Freeswitch do
  subject { build(:freeswitch_cdr) }

  describe "#uuid" do
    it { expect(subject.uuid).to eq("1b17f1e5-becb-4daa-8cb8-1ec822dd4297") }
  end

  describe "#direction" do
    it { expect(subject.direction).to eq("inbound") }
  end

  describe "#duration_sec" do
    it { expect(subject.duration_sec).to eq("1") }
  end

  describe "#bill_sec" do
    it { expect(subject.bill_sec).to eq("0") }
  end

  describe "#hangup_cause" do
    it { expect(subject.hangup_cause).to eq("ORIGINATOR_CANCEL") }
  end

  describe "#to_file" do
    def assert_file!
      content_type, filename, file = subject.to_file
      expect(content_type).to eq("application/json")
      expect(filename).to eq("a_1b17f1e5-becb-4daa-8cb8-1ec822dd4297.cdr.json")
      expect(file.read).to eq(subject.raw_cdr)
    end
    it { assert_file! }
  end
end

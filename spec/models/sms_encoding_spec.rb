require "rails_helper"

RSpec.describe SMSEncoding do
  describe "#detect" do
    it "handles GSM messages" do
      encoding = SMSEncoding.new

      result = encoding.detect("Hello World")

      expect(result.segments).to eq(1)
      expect(result.encoding).to eq("GSM")

      expect(encoding.detect("å").encoding).to eq("GSM")
      expect(encoding.detect("").segments).to eq(1)
      expect(encoding.detect("a" * 160).segments).to eq(1)
      expect(encoding.detect("a" * 161).segments).to eq(2)
      expect(encoding.detect("a" * 306).segments).to eq(2)
      expect(encoding.detect("a" * 307).segments).to eq(3)
      expect(encoding.detect("a" * 459).segments).to eq(3)
      expect(encoding.detect("a" * 500).segments).to eq(4)
    end

    it "handles UCS2 messages" do
      encoding = SMSEncoding.new

      result = encoding.detect("សំឡេង")

      expect(result.segments).to eq(1)
      expect(result.encoding).to eq("UCS2")
      expect(encoding.detect("").segments).to eq(1)
      expect(encoding.detect("ក" * 70).segments).to eq(1)
      expect(encoding.detect("ក" * 71).segments).to eq(2)
      expect(encoding.detect("ក" * 134).segments).to eq(2)
      expect(encoding.detect("ក" * 135).segments).to eq(3)
    end
  end
end

require "rails_helper"

RSpec.describe SmartEncoding do
  describe "#encode" do
    it "handles smart encoding" do
      smart_encoding = SmartEncoding.new

      result = smart_encoding.encode("«✽» foobar")

      expect(result.to_s).to eq('"*" foobar')
      expect(result.smart_encoded?).to eq(true)

      result = smart_encoding.encode("foobar")

      expect(result.to_s).to eq("foobar")
      expect(result.smart_encoded?).to eq(false)
    end
  end
end

require "rails_helper"

RSpec.describe SmartEncoding do
  describe "#encode" do
    it "handles smart encoding" do
      smart_encoding = SmartEncoding.new

      result = smart_encoding.encode("«✽» foobar")

      expect(result).to eq('"*" foobar')
    end
  end
end

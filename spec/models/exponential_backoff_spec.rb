require "rails_helper"

RSpec.describe ExponentialBackoff do
  describe "#delay" do
    it "calculates an exponential delay with jitter" do
      exponential_backoff = ExponentialBackoff.new(
        random_number_generator: -> { 1 }
      )

      result = exponential_backoff.delay(attempt: 10)

      expect(result).to eq(11502.0)
    end
  end
end

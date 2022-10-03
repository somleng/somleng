require "rails_helper"

RSpec.describe ExponentialBackoff do
  describe "#delay" do
    it "calculates an exponential delay with jitter" do
      fake_random_number_generator = build_fake_random_number_generator
      exponential_backoff = ExponentialBackoff.new(
        max_attempts: 10,
        max_retry_period: 1.hour,
        random_number_generator: fake_random_number_generator
      )

      result = exponential_backoff.delay(attempt: 10)

      expect(result).to eq(1.hour)
    end
  end

  describe "#max_total_delay" do
    it "returns the maximum total delay" do
      exponential_backoff = ExponentialBackoff.new(
        max_attempts: 10,
        max_retry_period: 1.hour
      )

      result = exponential_backoff.max_total_delay

      expect(result.to_i).to eq(6437)
    end
  end

  def build_fake_random_number_generator
    klass = Class.new do
      def call(range)
        range.last
      end
    end

    klass.new
  end
end

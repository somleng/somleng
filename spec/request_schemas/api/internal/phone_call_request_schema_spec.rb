require "rails_helper"

module API
  module Internal
    RSpec.describe PhoneCallRequestSchema, type: :request_schema do
      it { expect(validate_schema(To: nil)).not_to have_valid_field(:To) }
      it { expect(validate_schema(To: "2442")).to have_valid_field(:To) }
      it { expect(validate_schema(To: "+855 97 2345 678")).to have_valid_field(:To) }
      it { expect(validate_schema(To: "+855972345678")).to have_valid_field(:To) }

      it { expect(validate_schema(From: nil)).not_to have_valid_field(:From) }
      it { expect(validate_schema(From: "2442")).not_to have_valid_field(:From) }
      it { expect(validate_schema(From: "+855 97 2345 678")).to have_valid_field(:From) }
      it { expect(validate_schema(From: "+855972345678")).to have_valid_field(:From) }

      it { expect(described_class.call(From: "+855 97 2345 678").output.fetch(:From)).to eq("+855972345678") }
      it { expect(described_class.call(From: "097 2345 678").output.fetch(:From)).to eq("0972345678") }
    end
  end
end

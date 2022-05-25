require "rails_helper"

RSpec.describe SubdomainValidator do
  it "validates a subdomain" do
    validatable_klass = Struct.new(:subdomain) do
      include ActiveModel::Validations

      def self.model_name
        ActiveModel::Name.new(self, nil, "temp")
      end

      validates :subdomain, subdomain: true
    end

    existing_carrier = create(:carrier)

    expect(validatable_klass.new("my-company").valid?).to eq(true)
    expect(validatable_klass.new(existing_carrier.subdomain).valid?).to eq(false)
    expect(validatable_klass.new(nil).valid?).to eq(false)
    expect(validatable_klass.new("a").valid?).to eq(false)
  end
end

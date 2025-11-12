require "rails_helper"

RSpec.describe DestinationTariffForm do
  it "validates the presence of the destination group" do
    form = build_form(destination_group_id: nil)

    form.valid?

    expect(form.errors[:destination_group_id]).to be_present
  end

  describe "#save" do
    it "create a new tariff" do
      carrier = create(:carrier, billing_currency: "USD")
      schedule = create(:tariff_schedule, carrier:)
      destination_group = create(:destination_group, carrier:)

      form = build_form(
        schedule:,
        destination_group_id: destination_group.id,
        rate: "0.005"
      )

      form.save

      expect(form.object).to have_attributes(
        persisted?: true,
        schedule:,
        destination_group:,
        tariff: have_attributes(
          rate: InfinitePrecisionMoney.from_amount(0.005, "USD")
        )
      )
    end

    it "destroy a tariff" do
      carrier = create(:carrier)
      destination_tariff = create(:destination_tariff, carrier:)

      form = DestinationTariffForm.initialize_with(destination_tariff)
      form._destroy = true

      form.save

      expect(form.object).not_to be_persisted
    end

    it "update a tariff" do
      carrier = create(:carrier, billing_currency: "USD")
      schedule = create(:tariff_schedule, :outbound_messages, carrier:)
      destination_tariff = create(:destination_tariff, schedule:)

      form = DestinationTariffForm.initialize_with(destination_tariff)

      form.attributes = {
        rate: "0.001"
      }

      form.save

      expect(form.object).to have_attributes(
        persisted?: true,
        schedule:,
        destination_group: destination_tariff.destination_group,
        tariff: have_attributes(
          rate: InfinitePrecisionMoney.from_amount(0.001, "USD")
        )
      )

      expect(carrier.tariffs).to contain_exactly(
        form.object.tariff
      )
    end
  end

  def build_form(**attributes)
    carrier = attributes.fetch(:carrier) { build_stubbed(:carrier) }

    DestinationTariffForm.new(
      schedule: build_stubbed(:tariff_schedule, carrier:),
      destination_group_id: build_stubbed(:destination_group, carrier:).id,
      rate: "0.005",
      **attributes
    )
  end
end

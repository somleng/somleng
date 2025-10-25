require "rails_helper"

RSpec.describe DestinationTariffForm do
  it "validates the presence of the associations" do
    form = build_form(tariff_schedule_id: nil, destination_group_id: nil, tariff_id: nil)

    form.valid?

    expect(form.errors[:tariff_schedule_id]).to be_present
    expect(form.errors[:destination_group_id]).to be_present
    expect(form.errors[:tariff_id]).to be_present
  end

  it "validates the uniqueness of the tariff" do
    carrier = create(:carrier)
    destination_tariff = create(:destination_tariff, carrier:)

    form = build_form(
      carrier:,
      tariff_schedule_id: destination_tariff.tariff_schedule_id,
      destination_group_id: destination_tariff.destination_group_id,
      tariff_id: destination_tariff.tariff_id
    )

    form.valid?

    expect(form.errors[:tariff_id]).to be_present
  end

  it "only provides valid tariff options" do
    carrier = create(:carrier)
    tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:)

    tariff = create(:tariff, :call, carrier:)
    create(:tariff, :message, carrier:)

    form = DestinationTariffForm.new(
      carrier:,
      tariff_schedule_id: tariff_schedule.id,
    )

    tariff_options = form.tariff_options_for_select

    expect(tariff_options).to contain_exactly([ be_present, tariff.id ])
  end

  describe "#save" do
    it "saves the form" do
      carrier = create(:carrier)
      tariff_schedule = create(:tariff_schedule, carrier:)
      destination_group = create(:destination_group, carrier:)
      tariff = create(:tariff, carrier:)

      form = build_form(
        carrier:,
        tariff_schedule_id: tariff_schedule.id,
        destination_group_id: destination_group.id,
        tariff_id: tariff.id
      )

      form.save

      expect(form.object).to have_attributes(
        persisted?: true,
        tariff_schedule:,
        destination_group:,
        tariff:
      )
    end
  end

  def build_form(**attributes)
    carrier = attributes.fetch(:carrier) { build_stubbed(:carrier) }

    DestinationTariffForm.new(
      carrier:,
      tariff_schedule_id: build_stubbed(:tariff_schedule, carrier:).id,
      destination_group_id: build_stubbed(:destination_group, carrier:).id,
      tariff_id: build_stubbed(:tariff, carrier:).id,
      **attributes
    )
  end
end

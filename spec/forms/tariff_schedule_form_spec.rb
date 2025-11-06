require "rails_helper"

RSpec.describe TariffScheduleForm do
  it "validates the name" do
    carrier = create(:carrier)
    tariff_schedule = create(:tariff_schedule, :outbound_calls, carrier:, name: "Standard")

    form = build_form(carrier:)

    expect(form).to be_invalid
    expect(form.errors[:name]).to be_present

    form = build_form(carrier:, name: tariff_schedule.name, category: tariff_schedule.category)

    expect(form).to be_invalid
    expect(form.errors[:name]).to be_present

    form = TariffScheduleForm.initialize_with(tariff_schedule)
    form.name = tariff_schedule.name

    form.valid?

    expect(form.errors[:name]).to be_blank

    form = build_form(carrier:, name: tariff_schedule.name, category: "inbound_calls")

    form.valid?

    expect(form.errors[:name]).to be_blank
  end

  it "validates the category" do
    form = build_form(category: "wrong")

    form.valid?

    expect(form.errors[:category]).to be_present
  end

  describe "destination_groups" do
    it "validates the destination groups are unique on create" do
      carrier = create(:carrier)
      destination_group = create(:destination_group, carrier:)

      form = build_form(
        carrier:,
        destination_tariffs: 2.times.map { build_destination_tariff_form(destination_group_id: destination_group.id) }
      )

      expect(form).to be_invalid
      expect(form.errors[:destination_tariffs]).to be_present
      expect(form.destination_tariffs.first.errors[:destination_group_id]).to be_blank
      expect(form.destination_tariffs.last.errors[:destination_group_id]).to be_present
    end

    it "validates the destination groups are unique on update" do
      carrier = create(:carrier)
      destination_group = create(:destination_group, carrier:)
      tariff_schedule = create(:tariff_schedule, carrier:)
      destination_tariffs = [
        create(:destination_tariff, tariff_schedule:, destination_group:),
        create(:destination_tariff, tariff_schedule:)
      ]

      form = TariffScheduleForm.initialize_with(tariff_schedule)
      form.attributes = {
        destination_tariffs: [
          build_destination_tariff_form(
            id: destination_tariffs[0].id,
            _destroy: "true",
            destination_group_id: destination_group.id
          ),
          build_destination_tariff_form(
            id: destination_tariffs[1].id,
            destination_group_id: destination_group.id
          )
        ]
      }

      form.valid?

      expect(form.errors[:destination_tariffs]).to be_blank
    end
  end

  def build_form(**)
    TariffScheduleForm.new(
      carrier: build_stubbed(:carrier),
      **
    )
  end

  def build_destination_tariff_form(**)
    {
      destination_group_id: build_stubbed(:destination_group).id,
      rate: "0.005",
      **
    }
  end
end

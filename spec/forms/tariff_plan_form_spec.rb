require "rails_helper"

RSpec.describe TariffPlanForm do
  it "validates the name" do
    tariff_plan = create(:tariff_plan)

    form = build_form(name: nil)

    expect(form).to be_invalid
    expect(form.errors[:name]).to be_present

    form = build_form(
      name: tariff_plan.name,
      category: tariff_plan.category,
      carrier: tariff_plan.carrier
    )

    expect(form).to be_invalid
    expect(form.errors[:name]).to be_present
  end

  it "validates the category" do
    form = build_form(category: "foobar")

    expect(form).to be_invalid
    expect(form.errors[:category]).to be_present
  end

  it "validates the tiers" do
    tariff_schedule = build_stubbed(:tariff_schedule)

    form = build_form(tiers: 2.times.map { build_tier(tariff_schedule_id: tariff_schedule.id) })

    expect(form).to be_invalid
    expect(form.errors[:tiers]).to be_present
    expect(form.tiers.first.errors[:tariff_schedule_id]).to be_blank
    expect(form.tiers.last.errors[:tariff_schedule_id]).to be_present

    form = build_form(tiers: 2.times.map { build_tier(weight: 10) })

    expect(form).to be_invalid
    expect(form.errors[:tiers]).to be_present
    expect(form.tiers.first.errors[:weight]).to be_blank
    expect(form.tiers.last.errors[:weight]).to be_present
  end

  describe "#save" do
    it "creates a plan" do
      tariff_schedule = create(:tariff_schedule, :outbound_calls)

      form = build_form(
        carrier: tariff_schedule.carrier,
        name: "My Plan",
        category: "outbound_calls",
        description: "My Plan Description",
        tiers: [ build_tier(tariff_schedule_id: tariff_schedule.id, weight: 10) ]
      )

      expect(form.save).to be_truthy

      expect(form.object).to have_attributes(
        persisted?: true,
        name: "My Plan",
        description:  "My Plan Description",
        tiers: contain_exactly(
          have_attributes(
            schedule: tariff_schedule,
            weight: 10
          )
        )
      )
    end

    it "updates the plan" do
      tariff_plan = create(:tariff_plan)
      new_tariff_schedule = create(:tariff_schedule, carrier: tariff_plan.carrier, category: tariff_plan.category)
      retained_plan_tier = create(
        :tariff_plan_tier,
        plan: tariff_plan,
        weight: 10
      )
      deleted_plan_tier = create(
        :tariff_plan_tier,
        plan: tariff_plan,
        weight: 40
      )

      form = TariffPlanForm.initialize_with(tariff_plan)
      form.attributes = {
        name: "My Updated Plan",
        description: "My Updated Description",
        tiers: [
          build_tier(id: retained_plan_tier.id, tariff_schedule_id: retained_plan_tier.schedule_id, weight: 20),
          build_tier(tariff_schedule_id: new_tariff_schedule.id, weight: 30),
          build_tier(id: deleted_plan_tier.id, tariff_schedule_id: deleted_plan_tier.schedule_id, _destroy: true)
        ]
      }

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        name: "My Updated Plan",
        description: "My Updated Description",
        tiers: contain_exactly(
          have_attributes(
            id: retained_plan_tier.id,
            schedule: retained_plan_tier.schedule,
            weight: 20
          ),
          have_attributes(
            schedule: new_tariff_schedule,
            weight: 30
          )
        )
      )
    end
  end

  def build_form(**)
    TariffPlanForm.new(
      carrier: build_stubbed(:carrier),
      name: "Standard",
      category: "outbound_calls",
      **
    )
  end

  def build_tier(**)
    {
      tariff_schedule_id: build_stubbed(:tariff_schedule).id,
      **
    }
  end
end

require "rails_helper"

RSpec.describe TariffPlanTierForm do
  describe "#save" do
    it "creates a tariff plan tier" do
      tariff_plan = create(:tariff_plan)
      tariff_schedule = create(:tariff_schedule, category: tariff_plan.category, carrier: tariff_plan.carrier)

      form = build_form(tariff_plan:, tariff_schedule_id: tariff_schedule.id, weight: 20)

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        persisted?: true,
        plan: tariff_plan,
        schedule: tariff_schedule,
        weight: 20
      )
    end

    it "updates a tariff plan tier" do
      tariff_plan_tier = create(:tariff_plan_tier, weight: 10)

      form = TariffPlanTierForm.initialize_with(tariff_plan_tier)
      form.attributes = {
        id: tariff_plan_tier.id,
        weight: 20
      }

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        weight: 20
      )
    end

    it "destroys a tariff plan tier" do
      tariff_plan_tier = create(:tariff_plan_tier)

      form = TariffPlanTierForm.initialize_with(tariff_plan_tier)
      form.attributes = {
        id: tariff_plan_tier.id,
        _destroy: true
      }

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        persisted?: false
      )
    end
  end

  def build_form(**)
    TariffPlanTierForm.new(
      tariff_plan: build_stubbed(:tariff_plan),
      tariff_schedule_id: build_stubbed(:tariff_schedule).id,
      weight: 10,
      **
    )
  end
end

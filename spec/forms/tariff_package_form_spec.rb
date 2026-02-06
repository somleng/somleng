require "rails_helper"

RSpec.describe TariffPackageForm do
  it "validates the name" do
    package = create(:tariff_package)
    form = build_form(name: nil)

    form.valid?

    expect(form.errors[:name]).to be_present

    form = build_form(carrier: package.carrier, name: package.name)

    form.valid?

    expect(form.errors[:name]).to be_present
  end

  describe "#save" do
    it "updates a tariff package" do
      carrier = create(:carrier)
      tariff_package = create(:tariff_package, carrier:)
      retained_tariff_package_plan = create(:tariff_package_plan, package: tariff_package, category: :outbound_calls)
      deleted_tariff_package_plan = create(:tariff_package_plan, package: tariff_package, category: :inbound_calls)

      new_plan = create(:tariff_plan, carrier:, category: :inbound_calls)

      form = TariffPackageForm.initialize_with(tariff_package)
      form.attributes = {
        plans: [
          { id: retained_tariff_package_plan.id, plan_id: retained_tariff_package_plan.plan_id, category: :outbound_calls, enabled: true },
          { id: deleted_tariff_package_plan.id, enabled: false },
          { plan_id: new_plan.id, category: :inbound_calls, enabled: true }
        ]
      }

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        package_plans: contain_exactly(
          retained_tariff_package_plan,
          have_attributes(
            persisted?: true,
            plan: new_plan,
            category: "inbound_calls",
          ),
        )
      )
    end
  end

  def build_form(**params)
    object = params.fetch(:object) { build_stubbed(:tariff_package) }
    TariffPackageForm.new(
      object:,
      carrier: object.carrier,
      name: "Standard",
      **params
    )
  end
end

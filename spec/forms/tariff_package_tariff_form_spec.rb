require "rails_helper"

RSpec.describe TariffPackageTariffForm do
  it "validates the name" do
    carrier = create(:carrier)
    plan = create(:tariff_plan, carrier:)
    schedule = create(:tariff_schedule, carrier:)

    form = build_form(
      parent_form: TariffPackageWizardForm.new(carrier:, name: plan.name),
      category: plan.category
    )

    expect(form).to be_invalid
    expect(form.errors[:rate]).to be_present

    form = build_form(
      parent_form: TariffPackageWizardForm.new(carrier:, name: schedule.name),
      category: schedule.category
    )

    expect(form).to be_invalid
    expect(form.errors[:rate]).to be_present
  end

  def build_form(**params)
    carrier = params.fetch(:carrier) { build_stubbed(:carrier) }

    TariffPackageTariffForm.new(
      parent_form: TariffPackageWizardForm.new(carrier:),
      package: build_stubbed(:tariff_package, carrier:),
      rate: "0.01",
      enabled: true,
      category: build_stubbed(:tariff_plan).category,
      **params
    )
  end
end

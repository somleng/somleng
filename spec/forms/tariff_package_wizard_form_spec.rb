require "rails_helper"

RSpec.describe TariffPackageWizardForm do
  it "validates the name" do
    package = create(:tariff_package)
    form = build_form(name: nil)

    form.valid?

    expect(form.errors[:name]).to be_present

    form = build_form(name: package.name, object: package)

    form.valid?

    expect(form.errors[:name]).to be_present
  end

  it "validates at least one tariff is enabled" do
    form = build_form(
      tariffs: [
        build_tariff_form(enabled: false)
      ]
    )

    form.valid?

    expect(form.errors[:tariffs]).to be_present
    expect(form.tariffs.first.errors[:rate]).to be_present
  end

  it "validates the tariffs" do
    form = build_form(
      tariffs: [ build_tariff_form(enabled: true, rate: -1) ]
    )

    form.valid?

    expect(form.errors[:tariffs]).to be_present
    expect(form.tariffs.first.errors[:rate]).to be_present
  end

  def build_form(**params)
    object = params.fetch(:object) { build_stubbed(:tariff_package) }
    TariffPackageWizardForm.new(
      object:,
      carrier: object.carrier,
      name: "Standard",
      tariffs: [ build_tariff_form(package: object) ],
      **params
    )
  end

  def build_tariff_form(**)
    {
      enabled: true,
      category: "outbound_calls",
      package: build_stubbed(:tariff_package),
      **
    }
  end
end

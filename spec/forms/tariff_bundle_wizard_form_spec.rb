require "rails_helper"

RSpec.describe TariffBundleWizardForm do
  it "validates the name" do
    tariff_bundle = create(:tariff_bundle)
    form = build_form(name: nil)

    form.valid?

    expect(form.errors[:name]).to be_present

    form = build_form(name: tariff_bundle.name, object: tariff_bundle)

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
    object = params.fetch(:object) { build_stubbed(:tariff_bundle) }
    TariffBundleWizardForm.new(
      object:,
      carrier: object.carrier,
      name: "Standard",
      tariffs: [ build_tariff_form(tariff_bundle: object) ],
      **params
    )
  end

  def build_tariff_form(**)
    {
      enabled: true,
      category: "outbound_calls",
      tariff_bundle: build_stubbed(:tariff_bundle),
      **
    }
  end
end

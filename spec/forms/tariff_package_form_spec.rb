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

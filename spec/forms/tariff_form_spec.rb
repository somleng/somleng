require "rails_helper"

RSpec.describe TariffForm do
  it "validates the name" do
    form = build_form(name: "")

    form.valid?

    expect(form.errors[:name]).to be_present
  end

  it "validates the message rate" do
    form = build_form(category: "message", message_rate: "")

    form.valid?

    expect(form.errors[:message_rate]).to be_present
  end

  def build_form(**attributes)
    TariffForm.new(
      carrier: attributes.fetch(:carrier, build_stubbed(:carrier)),
      **attributes
    )
  end
end

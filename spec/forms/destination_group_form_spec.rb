require "rails_helper"

RSpec.describe DestinationGroupForm do
  it "validates the name" do
    form = DestinationGroupForm.new(name: "")

    form.valid?

    expect(form.errors[:name]).to be_present
  end

  it "validates the prefixes" do
    form = DestinationGroupForm.new(prefixes: [])

    form.valid?

    expect(form.errors[:prefixes]).to be_present
  end

  describe "#save" do
    it "creates a destination group" do
      form = build_form(
        name: "Smart Cambodia",
        prefixes: [ "85510", "85515", "85516" ]
      )

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        persisted?: true,
        name: "Smart Cambodia",
        prefixes: match_array(
          [
            have_attributes(prefix: "85510"),
            have_attributes(prefix: "85515"),
            have_attributes(prefix: "85516")
          ]
        )
      )
    end

    it "updates a destination group" do
      destination_group = create(:destination_group, name: "US Destinations", prefixes: [ "1" ])

      form = build_form(
        object: destination_group,
        carrier: destination_group.carrier,
        name: "Smart Cambodia",
        prefixes: [ "85510", "85515", "85516" ]
      )

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        id: destination_group.id,
        persisted?: true,
        name: "Smart Cambodia",
        prefixes: match_array(
          [
            have_attributes(prefix: "85510"),
            have_attributes(prefix: "85515"),
            have_attributes(prefix: "85516")
          ]
        )
      )
    end
  end

  def build_form(**attributes)
    DestinationGroupForm.new(
      carrier: attributes.fetch(:carrier) { create(:carrier) },
      name: "Smart Cambodia",
      prefixes: [ "85510", "85515", "85516" ],
      **attributes
    )
  end
end

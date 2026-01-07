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

  it "validates catch alls" do
    destination_group = create(:destination_group, :catch_all)
    form = build_form(catch_all: true, carrier: destination_group.carrier)

    form.valid?

    expect(form.errors[:name]).to be_present

    form = build_form(catch_all: false, carrier: destination_group.carrier)

    form.valid?

    expect(form.errors[:name]).to be_blank
  end

  describe "#save" do
    it "creates a destination group" do
      form = build_form(
        carrier: create(:carrier),
        name: "Smart Cambodia",
        prefixes: [ "85510", "85515", "85516" ]
      )

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        persisted?: true,
        name: "Smart Cambodia",
        prefixes: contain_exactly(
          have_attributes(prefix: "85510"),
          have_attributes(prefix: "85515"),
          have_attributes(prefix: "85516")
        )
      )
      expect(form.rating_engine_client).to have_received(:upsert_destination_group).with(form.object)
    end

    it "creates a catch all destination group" do
      form = build_form(
        carrier: create(:carrier),
        name: nil,
        prefixes: nil,
        catch_all: true
      )

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        persisted?: true,
        catch_all?: true,
        name: "Catch all"
      )
    end

    it "create a manual catch all destination group" do
      form = build_form(
        carrier: create(:carrier),
        name: "Foobar",
        prefixes: 9.downto(0).map(&:to_s),
        catch_all: false
      )

      expect(form.save).to be_truthy
      expect(form.object).to have_attributes(
        persisted?: true,
        catch_all?: true,
        name: "Catch all"
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
        prefixes: contain_exactly(
          have_attributes(prefix: "85510"),
          have_attributes(prefix: "85515"),
          have_attributes(prefix: "85516")
        )
      )
      expect(form.rating_engine_client).to have_received(:upsert_destination_group).with(form.object)
    end
  end

  def build_form(**attributes)
    DestinationGroupForm.new(
      carrier: attributes.fetch(:carrier) { build_stubbed(:carrier) },
      name: "Smart Cambodia",
      prefixes: [ "85510", "85515", "85516" ],
      catch_all: false,
      rating_engine_client: attributes.fetch(:rating_engine_client) {
        instance_spy(RatingEngineClient)
      },
      **attributes
    )
  end
end

require "rails_helper"

RSpec.describe FormCollectionType do
  it "handles form collection types" do
    person_class = Class.new do
      include ActiveModel::Model
      include ActiveModel::Attributes

      attribute :first_name
      attribute :last_name
    end

    person_form_class = Class.new(ApplicationForm) do
      attribute :name

      def self.initialize_with(person)
        new(
          name: [ person.first_name, person.last_name ].join(" ")
        )
      end
    end

    household_form_class = Class.new(ApplicationForm) do
      attribute :people,
      FormCollectionType.new(
        form: person_form_class,
        reject_if: ->(attributes) { attributes.with_indifferent_access[:name].blank? }
      ),
      default: -> { FormCollection.new(Array.new(3) { {} }, form: person_form_class) }
    end

    # defaults
    form = household_form_class.new
    expect(form.people).to have_attributes(
      size: 3
    )

    # reject_if
    form = household_form_class.new(
      people: {
        "0" => { name: "" }
      }
    )
    expect(form.people).to have_attributes(
      size: 0
    )

    # nested form attributes
    form = household_form_class.new(
      people: {
        "0" => { name: "John Doe" },
        "1" => { name: "Jane Smith" }
      }
    )
    expect(form.people).to contain_exactly(
      have_attributes(name: "John Doe"),
      have_attributes(name: "Jane Smith")
    )

    # nested array attributes
    form = household_form_class.new(
      people: [
        { name: "John Doe" },
        { name: "Jane Smith" }
      ]
    )
    expect(form.people).to contain_exactly(
      have_attributes(name: "John Doe"),
      have_attributes(name: "Jane Smith"),
    )

    # single nested form
    form = household_form_class.new(
      people: { name: "John Doe" },
    )
    expect(form.people).to contain_exactly(
      have_attributes(name: "John Doe")
    )

    # initialization from database
    form = household_form_class.new(
      people: [
        person_class.new(first_name: "John", last_name: "Doe"),
        person_class.new(first_name: "Jane", last_name: "Smith")
      ]
    )
    expect(form.people).to contain_exactly(
      have_attributes(name: "John Doe"),
      have_attributes(name: "Jane Smith")
    )

    # initialization from form collection
    form = household_form_class.new(
      people: FormCollection.new(
        [ person_form_class.new(name: "John Doe") ], form: person_form_class
      )
    )
    expect(form.people).to contain_exactly(
      have_attributes(name: "John Doe"),
    )
  end
end

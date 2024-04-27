require "rails_helper"

RSpec.describe MultiSelectFormComponent do
  it "allows the selection available and existing values" do
    component = MultiSelectFormComponent.new(
      available_values: [ :available ],
      existing_values: [ :existing ],
      selected_values: [ :available, :existing ],
    )

    expect(component.valid?).to be_truthy
  end

  it "does not allow the selection of other values" do
    component = MultiSelectFormComponent.new(
      available_values: [ :available ],
      existing_values: [ :existing ],
      selected_values: [ :foobar ],
    )

    expect(component.valid?).to be_falsey
  end

  it "correctly returns the values to remove" do
    component = MultiSelectFormComponent.new(
      available_values: [ :available ],
      existing_values: [ :existing ],
      selected_values: [ :available ],
    )

    expect(component.values_to_remove).to contain_exactly(:existing)
  end

  it "correctly returns the values to add" do
    component = MultiSelectFormComponent.new(
      available_values: [ :available ],
      existing_values: [ :existing ],
      selected_values: [ :available ],
    )

    expect(component.values_to_add).to contain_exactly(:available)
  end

  it "returns all the possible values" do
    component = MultiSelectFormComponent.new(
      available_values: [ :available ],
      existing_values: [ :existing ],
      selected_values: [ :available ],
    )

    expect(component.all_values).to match_array([ :existing, :available ])
  end
end

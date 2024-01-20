class MultiSelectFormComponent
  attr_reader :selected_values, :available_values, :existing_values

  def initialize(selected_values:, available_values:, existing_values:)
    @selected_values = selected_values
    @available_values = available_values
    @existing_values = existing_values
  end

  def valid?
    (selected_values - all_values).empty?
  end

  def all_values
    (available_values + existing_values).uniq
  end

  def values_to_remove
    existing_values - selected_values
  end

  def values_to_add
    selected_values - existing_values
  end
end

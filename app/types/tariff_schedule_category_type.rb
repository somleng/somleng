class TariffScheduleCategoryType < ActiveRecord::Type::String
  TariffScheduleCategory = Data.define(:value, :tariff_category, :description, :direction, :diagram_direction_symbol, :diagram_category) do
    delegate :to_s, :to_sym, to: :value
  end

  def cast(value)
    return value if value.is_a?(TariffScheduleCategory)

    case value.to_sym
    when :inbound_calls
      direction = :inbound
      tariff_category = :call
      description = "inbound calls from"
      diagram_category = "CALL"
      diagram_direction_symbol = "<-"
    when :inbound_messages
      direction = :inbound
      tariff_category = :message
      description = "inbound messages from"
      diagram_category = "MSG"
      diagram_direction_symbol = "<-"
    when :outbound_calls
      direction = :outbound
      tariff_category = :call
      description = "outbound calls to"
      diagram_category = "CALL"
      diagram_direction_symbol = "->"
    when :outbound_messages
      direction = :outbound
      tariff_category = :message
      description = "outbound messages to"
      diagram_category = "MSG"
      diagram_direction_symbol = "->"
    end

    TariffScheduleCategory.new(
      value:,
      tariff_category:,
      description:,
      direction: ActiveSupport::StringInquirer.new(direction.to_s),
      diagram_category:,
      diagram_direction_symbol:,
    )
  end
end

class TariffScheduleCategoryType < ActiveRecord::Type::String
  TariffScheduleCategory = Data.define(:value, :tariff_category, :rate_unit, :type, :description, :direction, :diagram_direction_symbol, :diagram_category) do
    delegate :to_s, :to_sym, to: :value
  end

  def cast(value)
    return value if value.is_a?(TariffScheduleCategory)

    case value.to_sym
    when :inbound_calls
      direction = :inbound
      type = :calls
      tariff_category = "call"
      rate_unit = "/ min"
      description = "inbound calls from"
      diagram_category = "CALL"
      diagram_direction_symbol = "<-"
    when :inbound_messages
      direction = :inbound
      type = :messages
      tariff_category = "message"
      rate_unit = "/ msg"
      description = "inbound messages from"
      diagram_category = "MSG"
      diagram_direction_symbol = "<-"
    when :outbound_calls
      direction = :outbound
      type = :calls
      tariff_category = "call"
      rate_unit = "/ min"
      description = "outbound calls to"
      diagram_category = "CALL"
      diagram_direction_symbol = "->"
    when :outbound_messages
      direction = :outbound
      type = :messages
      tariff_category = "message"
      rate_unit = "/ msg"
      description = "outbound messages to"
      diagram_category = "MSG"
      diagram_direction_symbol = "->"
    end

    TariffScheduleCategory.new(
      value:,
      tariff_category: ActiveSupport::StringInquirer.new(tariff_category.to_s),
      type: ActiveSupport::StringInquirer.new(type.to_s),
      rate_unit:,
      description:,
      direction: ActiveSupport::StringInquirer.new(direction.to_s),
      diagram_category:,
      diagram_direction_symbol:,
    )
  end
end

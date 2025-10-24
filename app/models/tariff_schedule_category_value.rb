class TariffScheduleCategoryValue < Enumerize::Value
  delegate :tariff_category, :type, :description, :direction, :diagram_direction_symbol, :diagram_category, to: :@tariff_schedule_category

  def initialize(...)
    super(...)
    @tariff_schedule_category = TariffScheduleCategoryType.new.cast(value)
  end
end

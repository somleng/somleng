class TariffCalculation
  attr_reader :tariff_plan, :destination, :result

  def initialize(tariff_plan:, **options)
    @tariff_plan = tariff_plan
    @destination = options[:destination]
  end

  def calculate
    return if destination.blank?

    @result = DestinationTariff
      .joins(:plans)
      .joins(destination_group: :prefixes)
      .where(plans: { id: tariff_plan.id })
      .where("? LIKE destination_prefixes.prefix || '%'", destination)
      .order("LENGTH(destination_prefixes.prefix) DESC, tariff_plan_tiers.weight DESC")
      .first
  end
end

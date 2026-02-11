class TariffCalculator
  def calculate(tariff_plan:, destination:)
    return if destination.blank?

    DestinationTariff
      .joins(:plans)
      .joins(destination_group: :prefixes)
      .where(plans: { id: tariff_plan.id })
      .where("? LIKE destination_prefixes.prefix || '%'", destination)
      .order("LENGTH(destination_prefixes.prefix) DESC, tariff_plan_tiers.weight DESC")
      .first
  end
end

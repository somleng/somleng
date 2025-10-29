class TariffCalculation
  attr_reader :tariff_package, :destination, :result

  def initialize(tariff_package:, **options)
    @tariff_package = tariff_package
    @destination = options[:destination]
  end

  def calculate
    return if destination.blank?

    DestinationTariff
      .joins(tariff_schedule: { tariff_plans: :tariff_package })
      .joins(destination_group: :prefixes)
      .where(tariff_packages: { id: tariff_package.id })
      .where("? LIKE destination_prefixes.prefix || '%'", destination)
      .order("LENGTH(destination_prefixes.prefix) DESC, tariff_plans.weight ASC")
      .first
  end
end

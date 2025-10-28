class TariffCalculation
  attr_reader :tariff_package, :destination, :result

  def initialize(tariff_package:, **options)
    @tariff_package = tariff_package
    @destination = options[:destination]
  end

  def calculate
    return if destination.blank?

    prefix = tariff_package.destination_prefixes.longest_match_for(destination)

    return if prefix.blank?

    @result = prefix.destination_group.tariffs.first.rate
  end
end

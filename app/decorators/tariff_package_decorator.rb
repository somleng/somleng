class TariffPackageDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :TariffPackage
  end

  def category
    object.category.text
  end

  def name
    "#{category} (#{object.name})"
  end

  def schedules
    object.schedules.order(tariff_plan_tiers: { weight: :desc })
  end

  private

  def object
    __getobj__
  end
end

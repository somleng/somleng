class DestinationGroupDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :DestinationGroup
  end

  def prefixes
    object.prefixes.pluck(:prefix).join(", ")
  end

  private

  def object
    __getobj__
  end
end

class DestinationGroupDecorator < SimpleDelegator
  class << self
    delegate :model_name, :human_attribute_name, to: :DestinationGroup
  end

  def prefixes
    summarize_list(object.prefixes.pluck(:prefix))
  end

  def prefixes_summary
    summarize_list(object.prefixes.pluck(:prefix), max: 3)
  end

  private

  def summarize_list(items, max: nil)
    return items.to_sentence if max.blank? || items.size <= max

    displayed = items.take(max)
    remaining = items.size - max

    [ *displayed, "#{remaining} more" ].to_sentence
  end

  def object
    __getobj__
  end
end

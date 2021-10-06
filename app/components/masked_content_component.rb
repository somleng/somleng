class MaskedContentComponent < ViewComponent::Base
  attr_reader :raw_content

  def initialize(raw_content:, start_from: 0, length: 20)
    @raw_content = raw_content
    @start_from = start_from
    @length = length
  end

  def render?
    raw_content.present?
  end

  def masked_content
    result = raw_content.dup
    result[start_from..-1] = "*" * length
    result
  end

  private

  attr_reader :start_from, :length
end

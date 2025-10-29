class DecoratedCollection
  include Enumerable

  delegate :each, to: :@items

  def initialize(items)
    @items = items.map { |item| item.decorated }
  end
end

class DecoratedCollection
  include Enumerable

  def initialize(items)
    @items = items
  end

  def each(&)
    @items.each do |item|
      yield(item.decorated)
    end
  end
end

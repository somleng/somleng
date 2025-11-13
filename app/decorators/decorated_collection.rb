class DecoratedCollection
  include Enumerable

  delegate :size, :to_sentence, to: :@items

  def initialize(items)
    @items = items
  end

  def each(&)
    @items.each do |item|
      yield(item.decorated)
    end
  end
end

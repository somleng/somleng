  class FormCollection
    include Enumerable

    delegate :[], :each, :first, :last, :empty?, :size, :count, to: :@items

    def initialize(items, form:)
      @items = items.map { |item| item.is_a?(form) ? item : form.new(**item) }
    end
  end

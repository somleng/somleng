module UsageRecord
  class Abstract
    attr_accessor :category, :data
    delegate :start_date, :end_date, :account, to: :data

    def initialize(category, data)
      self.category = category
      self.data = data
    end

    def collection
      scope.where(account: data.account)
    end

    def count
      collection.count
    end
  end
end

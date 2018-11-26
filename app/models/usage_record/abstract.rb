module UsageRecord
  class Abstract
    attr_accessor :category, :config
    delegate :start_date, :end_date, :account, to: :config

    def initialize(category, config)
      self.category = category
      self.config = config
    end

    def count
      collection.count
    end

    private

    def collection
      scope.where(account: config.account)
    end
  end
end

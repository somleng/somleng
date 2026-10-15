module OrderableResource
  extend ActiveSupport::Concern

  module ClassMethods
    def latest_first
      order(sequence_number: :desc)
    end
  end
end

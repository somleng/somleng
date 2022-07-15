class EventFilter < ResourceFilter
  class TypeFilter < ApplicationFilter
    filter_params do
      optional(:type).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(type: filter_params.fetch(:type))
    end
  end

  class EventableFilter < ApplicationFilter
    filter_params do
      optional(:eventable_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(eventable_id: filter_params.fetch(:eventable_id))
    end
  end

  filter_with TypeFilter, EventableFilter, DateFilter
end

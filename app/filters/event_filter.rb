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

  class PhoneCallIDFilter < ApplicationFilter
    filter_params do
      optional(:phone_call_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(phone_call_id: filter_params.fetch(:phone_call_id))
    end
  end

  class MessageIDFilter < ApplicationFilter
    filter_params do
      optional(:message_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(message_id: filter_params.fetch(:message_id))
    end
  end

  filter_with TypeFilter, PhoneCallIDFilter, :date_filter
end

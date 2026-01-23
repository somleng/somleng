class AccountFilter < ResourceFilter
  class StatusFilter < ApplicationFilter
    filter_params do
      optional(:status).value(:string, included_in?: Account.status.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(status: filter_params.fetch(:status))
    end
  end

  class TypeFilter < ApplicationFilter
    filter_params do
      optional(:type).value(:string, included_in?: Account.type.values)
    end

    def apply
      return super if filter_params.blank?

      case filter_params.fetch(:type)
      when "carrier_managed"
        super.merge(Account.carrier_managed)
      when "customer_managed"
        super.merge(Account.customer_managed)
      end
    end
  end

  class TariffPlanIDFilter < ApplicationFilter
    filter_params do
      optional(:tariff_plan_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.joins(:tariff_plans).where(tariff_plans: { id: filter_params.fetch(:tariff_plan_id) })
    end
  end

  class MetadataFilter < ApplicationFilter
    self.filter_schema = Dry::Validation.Contract do
      params do
        optional(:filter).schema do
          optional(:metadata).schema do
            required(:key).value(:string)
            required(:value).value(:string)
          end
        end
      end
    end

    def apply
      return super if filter_params[:metadata].blank?

      key = filter_params.dig(:metadata, :key)
      value = filter_params.dig(:metadata, :value)
      keys = key.split(".").join(",")

      super.where("metadata #>> :key = :value", key: "{#{keys}}", value:)
    end
  end

  filter_with(
    StatusFilter,
    TypeFilter,
    TariffPlanIDFilter,
    MetadataFilter,
    :id_filter,
    :date_filter
  )
end

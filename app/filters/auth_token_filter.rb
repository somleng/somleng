class AuthTokenFilter < ResourceFilter
  class ActiveFilter < ApplicationFilter
    filter_params do
      optional(:active).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      filter_params.fetch(:active) ? super.active : super.revoked
    end
  end

  class PrimaryFilter < ApplicationFilter
    filter_params do
      optional(:primary).value(:bool)
    end

    def apply
      return super if filter_params.blank?

      filter_params.fetch(:primary) ? super.primary : super.secondary
    end
  end

  filter_with(
    ActiveFilter,
    PrimaryFilter,
    :id_filter,
    :date_filter,
    {
      account_id_filter: {
        foreign_key: :resource_owner_id
      }
    }
  )
end

class AuthTokenFilter < ResourceFilter
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
    PrimaryFilter,
    :access_token_active_filter,
    :id_filter,
    :date_filter,
    {
      account_id_filter: {
        foreign_key: :resource_owner_id
      }
    }
  )
end

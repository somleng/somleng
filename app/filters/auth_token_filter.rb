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

  filter_with(
    ActiveFilter,
    :id_filter,
    :date_filter,
    {
      account_id_filter: {
        foreign_key: :resource_owner_id
      }
    }
  )
end

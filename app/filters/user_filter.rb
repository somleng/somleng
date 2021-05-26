class UserFilter < ResourceFilter
  class RoleFilter < ApplicationFilter
    filter_params do
      optional(:role).value(:string, included_in?: User.role.values)
    end

    def apply
      return super if filter_params.blank?

      super.where(role: filter_params.fetch(:role))
    end
  end

  filter_with RoleFilter, DateFilter
end

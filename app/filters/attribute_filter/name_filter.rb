module AttributeFilter
  class NameFilter < ApplicationFilter
    filter_params do
      optional(:name).value(:string)
    end

    def apply
      return super if filter_params.blank?

      arel_table = super.arel_table
      super.where(arel_table[:name].matches("%#{filter_params.fetch(:name)}%"))
    end
  end
end

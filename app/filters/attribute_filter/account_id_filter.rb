module AttributeFilter
  class AccountIDFilter < ApplicationFilter
    filter_params do
      optional(:account_id).value(:string)
    end

    def apply
      return super if filter_params.blank?

      super.where(options.fetch(:foreign_key, :account_id) => filter_params.fetch(:account_id))
    end
  end
end

class SubdomainType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    value.parameterize
  end
end

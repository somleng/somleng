class HostnameType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    URI(value).hostname || URI("//#{value}").hostname
  rescue URI::InvalidURIError
    value
  end
end

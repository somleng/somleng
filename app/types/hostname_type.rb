class HostnameType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    uri = URI(value.starts_with?("http") ? value : "http://#{value}")
    uri.hostname
  rescue URI::InvalidURIError
    value
  end
end

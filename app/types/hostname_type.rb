class HostnameType < ActiveRecord::Type::String
  def cast(value)
    return if value.blank?

    url = value.starts_with?("http") ? value : value.prepend("http://")
    uri = URI(url)
    uri.hostname
  rescue URI::InvalidURIError
    value
  end
end

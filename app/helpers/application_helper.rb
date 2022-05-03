module ApplicationHelper
  def carrier_logo(carrier)
    return carrier.logo if carrier&.logo&.attached?

    "placeholder_logo.png"
  end

  def local_time(time)
    return if time.blank?

    tag.time(time.utc.iso8601, data: { behavior: "local-time" })
  end
end

module ApplicationHelper
  def carrier_logo(carrier, options = {})
    if carrier&.logo&.attached?
      image_tag(carrier.logo, options.reverse_merge(alt: carrier.name))
    else
      image_tag("placeholder_logo.png", options)
    end
  end

  def carrier_favicon_url(carrier)
    if carrier&.logo&.attached?
      url_for(carrier.logo)
    else
      image_path("placeholder_logo.png")
    end
  end

  def local_time(time)
    return if time.blank?

    tag.time(time.utc.iso8601, data: { behavior: "local-time" })
  end
end

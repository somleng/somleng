module ApplicationHelper
  def carrier_logo(carrier, options = {})
    if carrier&.logo&.attached?
      image_tag(carrier.logo, options.reverse_merge(alt: carrier.name))
    else
      image_tag("placeholder_logo.png", options)
    end
  end

  def local_time(time)
    return if time.blank?

    tag.time(time.utc.iso8601, data: { behavior: "local-time" })
  end

  def find_carrier_from_domain
    CustomDomain.find_by(host: request.host, verified: true, type: :dashboard)&.carrier
  end
end

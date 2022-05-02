module ApplicationHelper
  def carrier_logo(carrier)
    return carrier.logo if carrier&.logo&.attached?

    "placeholder_logo.png"
  end
end

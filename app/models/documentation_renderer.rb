class DocumentationRenderer
  attr_reader :template, :carrier

  def initialize(template:, carrier:)
    @template = template
    @carrier = carrier
  end

  def render
    set_logo
    set_carrier_name
    set_api_host

    content
  end

  private

  def set_logo
    return unless carrier.logo.attached?

    html_doc = Nokogiri::HTML(content)

    logo = html_doc.at_css(".logo")
    logo[:src] = url_helpers.rails_blob_url(carrier.logo)
    logo[:alt] = carrier.name

    if carrier.favicon.attached?
      head = html_doc.at_css("head")
      favicon = html_doc.create_element("link", href: url_helpers.rails_blob_url(carrier.favicon), rel: "icon", size: "32x32")
      head.add_child(favicon)
    end

    @content = html_doc.to_html
  end

  def set_carrier_name
    content.gsub!(/Somleng/, carrier.name)
  end

  def set_api_host
    content.gsub!("api.somleng.org", carrier.custom_api_host) if carrier.custom_api_host.present?
  end

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end

  def content
    @content ||= template.read
  end
end

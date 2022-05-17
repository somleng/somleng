class DocumentationRenderer
  attr_reader :template, :custom_domain

  def initialize(template:, custom_domain:)
    @template = template
    @custom_domain = custom_domain
  end

  def render
    set_logo
    set_carrier_name

    content
  end

  private

  def carrier
    custom_domain.carrier
  end

  def set_logo
    return unless carrier.logo.attached?

    html_doc = Nokogiri::HTML(content)
    logo = html_doc.at_css(".logo")
    logo[:src] = url_helpers.rails_blob_url(carrier.logo)
    logo[:alt] = carrier.name
    @content = html_doc.to_html
  end

  def set_carrier_name
    content.gsub!("api.somleng.org", custom_domain.host)
    content.gsub!(/Somleng/, carrier.name)
  end

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end

  def content
    @content ||= template.read
  end
end

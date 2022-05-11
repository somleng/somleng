class DocumentationRenderer
  attr_reader :content, :custom_domain

  def initialize(content:, custom_domain: nil)
    @content = content.dup
    @custom_domain = custom_domain
  end

  def render
    return content if custom_domain.blank?

    set_logo
    set_carrier_name

    content.html_safe
  end

  private

  def carrier
    custom_domain.carrier
  end

  def set_logo
    return if carrier.logo.blank?

    html_doc = Nokogiri::HTML(content)
    logo = html_doc.at_css(".logo")
    logo[:src] = url_helpers.rails_blob_url(carrier.logo)
    logo[:alt] = carrier.name
    @content = html_doc.to_html
  end

  def set_carrier_name
    content.gsub!("api.somleng.org", custom_domain.host)
    content.gsub!(/somleng/i, carrier.name)
  end

  def url_helpers
    @url_helpers ||= Rails.application.routes.url_helpers
  end
end

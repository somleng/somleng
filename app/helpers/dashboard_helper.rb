module DashboardHelper
  def user_profile_image_url(user)
    user_email = Digest::MD5.hexdigest(user.email)
    "https://www.gravatar.com/avatar/#{user_email}?size=200"
  end

  def page_title(title:, subtitle: nil, &block)
    content_for(:page_title, title)

    content_tag(:div, class: "card-header d-flex justify-content-between align-items-center") do
      content = "".html_safe
      content += content_tag(:span, title, class: "h2")

      if subtitle.present?
        content += " "
        content += content_tag(:small, subtitle)
      end

      if block_given?
        content += content_tag(:div, class: "card-header-actions") do
          capture(&block)
        end
      end

      content
    end
  end

  def sidebar_nav(text, path, icon_class:, link_options: {})
    content_tag(:li, class: "nav-item") do
      sidebar_nav_class = "nav-link"
      sidebar_nav_class += " active" if request.path == path
      link_to(path, class: sidebar_nav_class, **link_options) do
        content = "".html_safe
        content += content_tag(:i, nil, class: "nav-icon #{icon_class}")
        content + " " + text
      end
    end
  end

  def external_link_to(text, *)
    link_to(*) do
      "".html_safe + text + " " + content_tag(:i, nil, class: "fa-solid fa-external-link-alt")
    end
  end

  def two_fa_qr_code(user)
    label = "Somleng:#{user.email}"
    content = "".html_safe
    content + RQRCode::QRCode.new(
      user.otp_provisioning_uri(label, issuer: "Somleng")
    ).as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 3,
      standalone: true
    ).html_safe
  end

  def mask_content(content, start_from: 0, length: 20)
    masked_content = content.dup
    masked_content[start_from..-1] = "*" * length

    content_tag(:div,
                data: { controller: "masked-content", masked_content_raw_content: content }) do
      content = "".html_safe
      content += content_tag(
        :code,
        masked_content,
        data: {
          "masked-content-target" => "content"
        }
      )
      content += " "
      content += content_tag(
        :button,
        class: "btn btn-light btn-sm",
        title: "Reveal",
        data: {
          "action" => "masked-content#reveal",
          "masked-content-target" => "revealButton"
        }
      ) do
        content_tag(:i, nil, class: "fa-solid fa-eye")
      end
    end
  end

  def image_thumbnail(image, width: 100, title: nil)
    return unless image.attached?

    link_to(
      image_tag(image, width:, title:, class: "img-thumbnail"),
      url_for(image),
      target: "_blank",
      rel: "noopener"
    )
  end

  def pretty_print_xml(xml)
    doc = Nokogiri.XML(xml) do |config|
      config.default_xml.noblanks
    end

    doc.to_xml(indent: 2)
  end

  def connection_status(sms_gateway)
    content = "".html_safe
    if sms_gateway.connected?
      content << content_tag(:i, "", class: "fas fa-circle text-success")
      content << " Connected "
      content << content_tag(
        :span,
        "#{time_ago_in_words(sms_gateway.last_connected_at)} ago",
        class: "text-muted small"
      )
    else
      content << (content_tag(:i, "", class: "fas fa-circle text-danger") + " Disconnected")
    end
  end

  def status_badge(color)
    icon_class = color == :success ? "fa-circle-check" : "fa-triangle-exclamation"
    tag.span(class: "text-#{color}") do
      tag.i(class: "fa-solid #{icon_class}")
    end
  end
end

module DashboardHelper
  def user_profile_image_url(user)
    user_email = Digest::MD5.hexdigest(user.email)
    "https://www.gravatar.com/avatar/#{user_email}?size=200"
  end

  def page_title(title:, subtitle: nil, &block)
    content_for(:page_title, title)

    content_tag(:div, class: "card-header") do
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

  def sidebar_nav(text, path, icon_class:)
    content_tag(:li, class: "c-sidebar-nav-item") do
      sidebar_nav_class = "c-sidebar-nav-link"
      sidebar_nav_class += " c-active" if request.path == path
      link_to(path, class: sidebar_nav_class) do
        content = "".html_safe
        content += content_tag(:i, nil, class: "c-sidebar-nav-icon #{icon_class}")
        content + " " + text
      end
    end
  end

  def external_link_to(text, *args)
    link_to(*args) do
      "".html_safe + text + " " + content_tag(:i, nil, class: "fas fa-external-link-alt")
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
        class: "btn btn-secondary btn-sm",
        title: "Reveal",
        data: {
          "action" => "masked-content#reveal",
          "masked-content-target" => "revealButton"
        }
      ) do
        content_tag(:i, nil, class: "fas fa-eye")
      end
    end
  end

  def local_time(time)
    return if time.blank?

    tag.time(time.utc.iso8601, data: { behavior: "local-time" })
  end

  def image_thumbnail(image)
    return unless image.attached?

    link_to(
      image_tag(image, width: 100, class: "img-thumbnail"),
      url_for(image),
      target: "_blank",
      rel: "noopener"
    )
  end
end

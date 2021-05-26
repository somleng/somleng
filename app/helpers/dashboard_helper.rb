module DashboardHelper
  def user_profile_image_url(user)
    user_email = Digest::MD5.hexdigest(user.email)
    "https://www.gravatar.com/avatar/#{user_email}?size=200"
  end

  def page_title(title:, &block)
    content_for(:page_title, title)

    content_tag(:div, class: "card-header") do
      content = content_tag(:span, title, class: "h2")
      if block_given?
        content += content_tag(:div, class: "card-header-actions") do
          capture(&block)
        end
      end

      content.html_safe
    end
  end

  def sidebar_nav(text, path, icon_class:)
    content_tag(:li, class: "c-sidebar-nav-item") do
      sidebar_nav_class = "c-sidebar-nav-link"
      sidebar_nav_class += " c-active" if request.path == path
      link_to(path, class: sidebar_nav_class) do
        icon = content_tag(:i, nil, class: "c-sidebar-nav-icon #{icon_class}")
        [icon, text].join(" ").html_safe
      end
    end
  end

  def two_fa_qr_code(user)
    label = "Somleng:#{user.email}"
    RQRCode::QRCode.new(
      user.otp_provisioning_uri(label, issuer: "Somleng")
    ).as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 3,
      standalone: true
    ).html_safe
  end
end

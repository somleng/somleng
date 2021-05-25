module ApplicationHelper
  def preview_asset(attachment)
    return unless attachment.attached?

    link_to(
      attachment.image? ? image_tag(attachment, width: 100) : attachment.filename,
      url_for(attachment),
      target: "_blank",
      rel: "noopener"
    )
  end

  def local_time(time)
    return if time.blank?

    tag.time(time.utc.iso8601, data: { behavior: "local-time" })
  end
end

class CustomDomainRequest < SimpleDelegator
  def custom_domain_request?
    request.headers.key?("HTTP_X_FORWARDED_HOST")
  end

  def app_hostname
    ActionDispatch::Request.new(
      request.env.except("HTTP_X_FORWARDED_HOST")
    ).hostname
  end

  def custom_domain_hostname
    request.hostname
  end

  def find_custom_domain!(context, options = {})
    return unless custom_domain_request?

    CustomDomain.verified.find_by!(
      host: custom_domain_hostname,
      type: context,
      **options
    )
  end

  private

  def request
    __getobj__
  end
end

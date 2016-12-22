class Api::Usage::RecordsResponder < Api::BaseResponder
  def to_format
    if get? && has_errors? && !response_overridden?
      display_errors
    else
      super
    end
  end
end

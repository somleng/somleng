class CreateErrorLog < ApplicationWorkflow
  attr_reader :params

  def initialize(params)
    @params = params
  end

  def call
    create_error_log
    notify_owner
    error_log
  end

  private

  attr_reader :error_log

  def create_error_log
    @error_log = ErrorLog.create!(params)
  end

  def notify_owner
    owner = resolve_owner
    return if owner.blank?
    return if last_notified_at < 1.day.ago

    error_log.notifications.create!(email: owner.email)
  end

  def user_to_be_notified
    if error_log.account.present?
      error_log.account.owner
    elsif error_log.carrier.present?
      error_log.carrier.owner
    end
  end

  def log_owner
    error_log.account || error_log.carrier
  end

  def last_notified_at

  end
end

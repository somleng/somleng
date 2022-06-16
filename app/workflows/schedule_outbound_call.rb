class ScheduleOutboundCall < ApplicationWorkflow
  attr_reader :phone_call

  def initialize(phone_call)
    @phone_call = phone_call
  end

  def call
    ScheduledJob.perform_later(
      OutboundCallJob.to_s,
      phone_call,
      wait_until: calculate_delay.seconds.from_now
    )
  end

  private

  def account
    phone_call.account
  end

  def queued_phone_calls
    account.phone_calls.queued
  end

  def calculate_delay
    queued_phone_calls.count.to_f / account.calls_per_second
  end
end

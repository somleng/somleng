class AdvisoryLock
  class << self
    def allocate_sip_trunk_channel(sip_trunk, options = {}, &block)
      with_lock("allocate_sip_trunk_channel:#{sip_trunk.id}", options, &block)
    end

    private

    def with_lock(key, options, &block)
      options.reverse_merge!(
        timeout_seconds: 15.seconds,
        transaction: true
      )
      ApplicationRecord.transaction do
        ApplicationRecord.with_advisory_lock(key, options, &block)
      end
    end
  end
end

module StateMachine
  class ActiveRecord < Machine
    attr_reader :record

    def initialize(record)
      @record = record
      super(record.status)
    end

    def transition_to(new_state, **options)
      record.status = super(new_state).name
      persist!(record.status, **options) if record.status_changed?
    end

    def transition_to!(new_state, **options)
      record.status = super(new_state).name
      persist!(record.status, **options)
    end

    private

    def persist!(new_state, **options)
      record.transaction do
        record.save!
        timestamp_attribute = options.fetch(:touch) if options.key?(:touch)
        raise(ArgumentError, "Unknown timestamp attribute #{timestamp_attribute}") if timestamp_attribute.present? && !record.has_attribute?(timestamp_attribute)
        timestamp_attribute ||= "#{new_state}_at"
        record.touch(timestamp_attribute) if record.has_attribute?(timestamp_attribute)
      end
    end
  end
end

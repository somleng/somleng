module StateMachine
  class ActiveRecord < Machine
    attr_reader :record

    def initialize(record)
      @record = record
      super(record.status)
    end

    def may_transition_to?(new_state)
      self.class.new(record.dup).transition_to(new_state, persist: false)
    end

    def transition_to(new_state, persist: true, **options)
      return unless super(new_state)

      record.status = current_state.name
      persist ? persist!(record.status, **options) { record.save } : record.valid?
      record.errors.empty?
    end

    def transition_to!(new_state, **options)
      super(new_state)
      record.status = current_state.name
      persist!(record.status, **options) { record.save! }
    end

    private

    def persist!(new_state, **options)
      record.transaction do
        return unless yield

        timestamp_attribute = options.fetch(:touch) if options.key?(:touch)
        raise(ArgumentError, "Unknown timestamp attribute #{timestamp_attribute}") if timestamp_attribute.present? && !record.has_attribute?(timestamp_attribute)
        timestamp_attribute ||= "#{new_state}_at"
        record.touch(timestamp_attribute) if record.has_attribute?(timestamp_attribute)
      end

      true
    end
  end
end

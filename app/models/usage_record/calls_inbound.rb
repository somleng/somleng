module UsageRecord
  class CallsInbound < Calls
    def description
      "Inbound Voice Minutes"
    end

    private

    def scope
      super.merge(CallDataRecord.inbound)
    end
  end
end

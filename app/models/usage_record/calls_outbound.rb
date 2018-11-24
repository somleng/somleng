module UsageRecord
  class CallsOutbound < Calls
    def description
      "Outbound Voice Minutes"
    end

    private

    def scope
      super.merge(CallDataRecord.outbound)
    end
  end
end

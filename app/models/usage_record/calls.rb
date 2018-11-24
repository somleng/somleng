module UsageRecord
  class Calls < Abstract
    def description
      "Voice Minutes"
    end

    def usage_unit
      "minutes"
    end

    def count_unit
      "calls"
    end

    def price
      Money.new(collection.sum(:price_microunits), "USD6").exchange_to("USD")
    end

    def usage
      collection.sum("((\"#{CallDataRecord.table_name}\".\"bill_sec\" - 1) / 60) + 1")
    end

    private

    def scope
      PhoneCall.joins(
        :call_data_record
      ).merge(
        CallDataRecord.billable
      ).merge(
        CallDataRecord.where(start_time: (data.start_date..data.end_date))
      )
    end
  end
end

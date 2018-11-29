module API
  module Internal
    class CallDataRecordsController < BaseController
      def create
        enqueue_process!(request.raw_post)
        head(:created)
      end

      private

      def enqueue_process!(cdr)
        CallDataRecordJob.perform_later(cdr)
      end
    end
  end
end

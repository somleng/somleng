class ApplicationJob < ActiveJob::Base
  retry_on ActiveRecord::StaleObjectError
end

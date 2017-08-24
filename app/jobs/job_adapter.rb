class JobAdapter
  attr_accessor :job_name

  delegate :configuration, :queue_adapter, :use_active_job?, :to => :class

  def initialize(job_name)
    self.job_name = job_name
  end

  def self.configuration(*keys)
    ENV["active_job_#{keys.compact.join('_')}".upcase]
  end

  def self.queue_adapter
    configuration(:queue_adapter)
  end

  def self.use_active_job?
    configuration(:use_active_job).to_i == 1
  end

  def perform_later(*args)
    passthrough? ? send("perform_later_#{queue_adapter}", *args) : perform_later_active_job(*args)
  end

  def passthrough?
    !use_active_job? && queue_adapter
  end

  private

  def perform_later_active_job(*args)
    active_job_worker_class.set(:queue => queue_name).perform_later(*args)
  end

  def perform_later_sidekiq(*args)
    Sidekiq::Client.enqueue_to(
      queue_name,
      sidekiq_worker_class,
      *args
    )
  end

  def perform_later_shoryuken(*args)
    Shoryuken::Client.queues(queue_name).send_message(*args)
  end

  def active_job_worker_class
    case job_name.to_sym
    when :outbound_call_worker
      OutboundCallJob
    when :call_data_record_worker
      CallDataRecordJob
    when :status_callback_notifier_worker
      StatusCallbackNotifierJob
    when :recording_processor_worker
      RecordingProcessorJob
    end
  end

  def sidekiq_worker_class
    meta_programming_helper.safe_define_class(class_name, Class.new { include Sidekiq::Worker })
  end

  def meta_programming_helper
    @meta_programming_helper ||= MetaProgrammingHelper.new
  end

  def queue_name
    job_configuration(:queue)
  end

  def class_name
    job_configuration(:class)
  end

  def job_configuration(key)
    configuration(queue_adapter, job_name, key)
  end
end

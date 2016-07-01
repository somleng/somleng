class JobAdapter
  attr_accessor :job_name

  delegate :configuration, :queue_adapter, :to => :class

  def initialize(job_name)
    self.job_name = job_name
  end

  def self.configuration(*keys)
    Rails.application.secrets["active_job_#{keys.compact.join('_')}"]
  end

  def self.queue_adapter
    configuration(:queue_adapter)
  end

  def perform_later(*args)
    if queue_adapter
      send("perform_later_#{queue_adapter}", *args)
    else
      active_job_class = (class_name && Object.const_defined?(class_name)) ? class_name.constantize : ActiveJob::Base
      active_job_class.perform_later(*args)
    end
  end

  private

  def perform_later_sidekiq(*args)
    Sidekiq::Client.enqueue_to(
      queue_name,
      sidekiq_worker_class,
      *args
    )
  end

  def sidekiq_worker_class
    (Object.const_defined?(class_name) && Object.const_get(class_name)) || Object.const_set(class_name, Class.new { include Sidekiq::Worker })
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

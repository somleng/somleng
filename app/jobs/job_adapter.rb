class JobAdapter
  attr_accessor :job_name

  delegate :configuration, :queue_adapter, :to => :class

  def initialize(job_name)
    self.job_name = job_name
  end

  def self.configuration(*keys)
    ENV["active_job_#{keys.compact.join('_')}".upcase]
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

  def perform_later_shoryuken(*args)
    Shoryuken::Client.queues(queue_name).send_message(*args)
  end

  def sidekiq_worker_class
    safe_define_class(class_name, Class.new { include Sidekiq::Worker })
  end

  def safe_define_class(name, klass)
    name_parts = name.split("::").reject(&:empty?)
    worker_const_name = name_parts.pop
    parent_const = nil
    module_parts = []
    name_parts.each do |name_part|
      module_parts << name_part
      parent_const = safe_define_const(module_parts, Module.new, parent_const)
    end
    module_parts << worker_const_name
    safe_define_const(module_parts, klass, parent_const)
  end

  def safe_define_const(parts, klass, parent_const)
    parent_const ||= Object
    name = parts.last
    path = parts.join("::")
    (parent_const.const_defined?(path) && parent_const.const_get(path)) || parent_const.const_set(name, klass)
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

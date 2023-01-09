class ExponentialBackoff
  JITTER_DEFAULT = 0.15

  attr_reader :random_number_generator

  def initialize(options = {})
    @random_number_generator = options.fetch(:random_number_generator, -> { Kernel.rand })
  end

  # https://github.com/rails/rails/blob/83217025a171593547d1268651b446d3533e2019/activejob/lib/active_job/exceptions.rb#L136
  def delay(attempt:)
    ((attempt**4) + (random_number_generator.call * (attempt**4) * JITTER_DEFAULT)) + 2
  end
end

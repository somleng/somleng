class AggregateData
  class IDGenerator
    def generate_id(key)
      Digest::SHA256.hexdigest(key.reject(&:blank?).map(&:downcase).join(":"))
    end
  end

  attr_reader :key, :groups, :value, :sequence_number, :id_generator

  def initialize(**options)
    @key = options.fetch(:key)
    @groups = options.fetch(:groups)
    @value = options.fetch(:value)
    @sequence_number = options.fetch(:sequence_number)
    @id_generator = options.fetch(:id_generator) { IDGenerator.new }
  end

  def id
    id_generator.generate_id(key)
  end
end

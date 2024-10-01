class AggregateDataQuery
  attr_reader :named_scopes, :conditions, :groups, :having

  def initialize(**options)
    @named_scopes = Array(options[:named_scopes])
    @conditions = options.fetch(:conditions, {})
    @groups = Array(options.fetch(:groups))
    @having = options.fetch(:having, {})
  end

  def apply(scope)
    named_scopes.each do |named_scope|
      scope = scope.public_send(named_scope)
    end

    result = scope.where(conditions).group(groups.map(&:column)).having(having_clause_for(scope.arel_table[:count])).count
    result.map.with_index do |(key, value), index|
      AggregateData.new(groups:, key:, value:, sequence_number: index + 1)
    end
  end

  private

  def having_clause_for(count)
    return {} if having.blank?

    operator, value = having.fetch(:count).first

    case operator
    when :eq
      count.eq(value)
    when :neq
      count.not_eq(value)
    when :gt
      count.gt(value)
    when :gteq
      count.gteq(value)
    when :lt
      count.lt(value)
    when :lteq
      count.lteq(value)
    end
  end
end

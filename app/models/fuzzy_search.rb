class FuzzySearch
  attr_reader :scope, :column

  def initialize(scope, column:)
    @scope = scope
    @column = column
  end

  def apply(search_term)
    return scope if search_term.blank?

    term = "%#{scope.model.sanitize_sql_like(search_term.squish)}%"
    scope.where(arel_table[column].matches(term, nil, false))
  end

  private

  def arel_table
    @scope.model.arel_table
  end
end

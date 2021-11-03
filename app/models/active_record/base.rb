# frozen_string_literal: true

class ActiveRecord::Base

  # @return [Array<Symbol>] names of Boolean columns which can store `NULL` values
  # @example
  #  Company.tristate_column_names
  #  #=> [:is_profitable, :is_run_by_psychopaths, :evades_taxation, ...]
  #
  def self.tristate_column_names
    columns.select { |col| col.type == :boolean && col.null }.map(&:name)
  end

end

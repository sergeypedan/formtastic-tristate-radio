# frozen_string_literal: true

class ActiveRecord::Base

  # @return [Array] of symbols — names of Boolean columns, which can be `NULL`
  def self.tristate_column_names
    columns.select { |col| col.type == :boolean && col.null }.map(&:name)
  end

end

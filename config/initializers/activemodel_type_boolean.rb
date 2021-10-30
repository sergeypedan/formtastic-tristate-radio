# frozen_string_literal: true

module ActiveModel
  module Type
    class Boolean < Value
      NULL_VALUES = [nil, "", "null"].to_set.freeze
      private def cast_value(value)
        NULL_VALUES.include?(value) ? nil : !FALSE_VALUES.include?(value)
      end
    end
  end
end

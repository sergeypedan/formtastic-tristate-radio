# frozen_string_literal: true

module ActiveModel
  module Type
    class Boolean < Value
      NULL_VALUES = [nil, "", "null", :null, "nil", :nil].to_set.freeze
      private def cast_value(value)
        converted = NULL_VALUES.include?(value) ? nil : !FALSE_VALUES.include?(value)
        puts "Original value #{value.inspect} converted into #{converted.inspect}"
        return converted
      end
    end
  end
end

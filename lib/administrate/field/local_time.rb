require "administrate/field/base"

module Administrate
  module Field
    class LocalTime < Administrate::Field::Base
      def to_s
        data&.utc&.iso8601
      end
    end
  end
end

require "administrate/field/base"

module Administrate
  module Field
    class EnumerizeSet < Administrate::Field::Base
      def to_s
        data.texts
      end
    end
  end
end

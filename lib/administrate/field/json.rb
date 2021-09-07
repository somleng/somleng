require "administrate/field/base"

module Administrate
  module Field
    class JSON < Administrate::Field::Base
      def to_s
        data.to_json
      end
    end
  end
end

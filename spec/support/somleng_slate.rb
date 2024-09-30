module RspecApiDocumentation
  module Writers
    class SomlengSlateWriter < SlateWriter
      def markup_example_class
        SomlengSlateExample
      end
    end
  end
end

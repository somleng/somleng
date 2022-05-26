module SimpleFormComponents
  module InputGroup
    def prepend(_wrapper_options = nil)
      span_tag = content_tag(:span, options[:prepend], class: "input-group-text")
      template.content_tag(:div, span_tag, class: "input-group-prepend")
    end

    def append(_wrapper_options = nil)
      span_tag = content_tag(:span, options[:append], class: "input-group-text")
      template.content_tag(:div, span_tag, class: "input-group-append")
    end
  end
end

# Register the component in Simple Form.
SimpleForm.include_component(SimpleFormComponents::InputGroup)

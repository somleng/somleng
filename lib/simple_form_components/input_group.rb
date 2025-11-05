# custom component requires input group wrapper
module SimpleFormComponents
  module InputGroup
    def prepend(_wrapper_options = nil)
      template.content_tag(:span, options[:prepend], class: "input-group-text", data: input_html_options.dig(:data, :prepend_data))
    end

    def append(_wrapper_options = nil)
      template.content_tag(:span, options[:append], class: "input-group-text", data: input_html_options.dig(:data, :append_data))
    end
  end
end

# Register the component in Simple Form.
SimpleForm.include_component(SimpleFormComponents::InputGroup)

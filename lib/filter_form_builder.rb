class FilterFormBuilder < ActionView::Helpers::FormBuilder
  def date_range(options)
    title = options.fetch(:title)
    from_date, to_date = options.fetch(:filter_value)
    hint = options[:hint]
    picker_options = options.fetch(:picker_options, {})

    if options[:restrict_date_range]
      hint ||= "Max 3 months"
      picker_options[:max_date_range_months] ||= 3
    end

    @template.render("shared/filters/field", filter_value: from_date, title:) do
      @template.tag.div(data: { controller: "filters--date-picker" }) do
        input_box = @template.text_field_tag(
          nil, nil,
          class: "form-control",
          placeholder: "Enter date",
          data: {
            "filters--date-picker-target" => "dateRangePicker",
            **picker_options
          }
        )

        hint_element = @template.tag.div(class: "form-text") do
          hint
        end

        from_date_hidden_field = hidden_field(
          :from_date,
          value: from_date,
          data: {
            "filters--date-picker-target" => "fromDate"
          }
        )
        to_date_hidden_field = hidden_field(
          :to_date,
          value: to_date,
          data: {
            "filters--date-picker-target" => "toDate"
          }
        )

        input_box + hint_element + from_date_hidden_field + to_date_hidden_field
      end
    end
  end

  def select(name, choices = nil, options = {}, html_options = {}, &)
    title = options.fetch(:title, name.to_s.humanize)
    filter_value = options.fetch(:filter_value)
    options[:selected] ||= filter_value
    html_options[:class] ||= "form-control"

    @template.render("shared/filters/field", filter_value:, title:) do
      super
    end
  end

  def boolean_select(name, options = {}, html_options = {}, &)
    choices = [
      [ I18n.t("show_for.yes"), true ],
      [ I18n.t("show_for.no"), false ]
    ]
    select(name, choices, options, html_options, &)
  end

  def key_value(name, key, value, options = {})
    @template.render(
      "shared/filters/field",
      filter_value: key,
      title: options.fetch(:title, name.to_s.humanize)
    ) do
      template = "".html_safe
      template += @template.tag.div(class: "mb-3") do
        form_group = "".html_safe
        form_group += label("#{name}_key", "Key")
        form_group += @template.text_field_tag("#{@object_name}[#{name}][key]", key,
                                               class: "form-control", placeholder: "customer.id")
        form_group
      end
      template += @template.tag.div(class: "mb-3") do
        form_group = "".html_safe
        form_group += label("#{name}_value", "Value")
        form_group += @template.text_field_tag("#{@object_name}[#{name}][value]", value,
                                               class: "form-control", placeholder: "abcd1234")
        form_group
      end
      template
    end
  end

  def text_field_tag(name, value, options = {})
    @template.render(
      "shared/filters/field",
      filter_value: value,
      title: options.fetch(:title, name.to_s.humanize)
    ) do
      @template.text_field_tag("#{@object_name}[#{name}]", value, class: "form-control", **options)
    end
  end
end

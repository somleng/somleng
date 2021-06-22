class FilterFormBuilder < ActionView::Helpers::FormBuilder
  def date_range(options)
    title = options.fetch(:title)
    from_date, to_date = options.fetch(:filter_value)

    @template.render("shared/filters/field", filter_value: from_date, title: title) do
      @template.tag.div(data: { controller: "filters--date-picker" }) do
        input_box = @template.text_field_tag(nil, nil, class: "form-control", data: { "filters--date-picker-target" => "dateRangePicker" })
        from_date_hidden_field = hidden_field(:from_date, value: from_date, data: { "filters--date-picker-target" => "fromDate" })
        to_date_hidden_field = hidden_field(:to_date, value: to_date, data: { "filters--date-picker-target" => "toDate" })

        input_box + from_date_hidden_field + to_date_hidden_field
      end
    end
  end

  def select(name, choices = nil, options = {}, html_options = {}, &block)
    title = options.fetch(:title, name.to_s.humanize)
    filter_value = options.fetch(:filter_value)
    options[:selected] ||= filter_value
    html_options[:class] ||= "form-control"

    @template.render("shared/filters/field", filter_value: filter_value, title: title) do
      super
    end
  end
end

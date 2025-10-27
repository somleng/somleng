module TariffHelper
  def destination_tariff_diagram(destination_tariff)
    category = destination_tariff.tariff_schedule.category
    destination_group = link_to(truncate(destination_tariff.destination_group_name, length: 10), dashboard_destination_group_path(destination_tariff.destination_group_id))
    tariff = link_to(truncate(destination_tariff.tariff_name, length: 20), dashboard_tariff_path(destination_tariff.tariff_id))
    diagram_category = category.diagram_category

    tag.span(title: destination_tariff_description(destination_tariff), data: { "bs-toggle" => "tooltip" }) do
      diagram_components = if category.direction.inbound?
        [ tariff, destination_group, diagram_category ]
      elsif category.direction.outbound?
        [ diagram_category, destination_group, tariff ]
      end

      safe_join(diagram_components, " #{category.diagram_direction_symbol} ")
    end
  end

  def destination_tariff_description(destination_tariff)
    template = "On the \"%<tariff_schedule>s\" tariff schedule, %<description>s %<destination_group>s are priced at %<tariff_cost>s."
    tariff_schedule = destination_tariff.tariff_schedule

    format(
      template,
      tariff_schedule: tariff_schedule.name,
      description: tariff_schedule.category.description,
      destination_group: destination_tariff.destination_group.name,
      tariff_cost: destination_tariff.tariff_name
    )
  end

  def tariff_bundle_packages(tariff_bundle)
    tag.span(class: "d-flex gap-3") do
      content = "".html_safe
      group_collection_by(tariff_bundle.line_items) { _1.category.type }.each do |category_type, line_items|
        group_content = "".html_safe
        content += tag.span(class: "d-inline-flex align-items-center gap-1") do
          next if line_items.blank?

          group_content += link_to_tariff_category_direction(line_items.find { _1.category.direction.outbound? }&.tariff_package)
          icon = if category_type.messages?
            "fa-comment-dots"
          elsif category_type.calls?
            "fa-phone"
          end
          group_content += tag.i(class: "fa-solid #{icon}").html_safe
          group_content += link_to_tariff_category_direction(line_items.find { _1.category.direction.inbound? }&.tariff_package)
        end
      end

      content
    end
  end

  def link_to_tariff_category_direction(linkable)
    return "" if linkable.blank?

    tag.span(class: "d-inline-flex align-items-center gap-0") do
      link_to([ :dashboard, linkable ], title: linkable.decorated.name, data: { "bs-toggle" => "tooltip" }, target: "_blank") do
        tariff_category_direction_icon(linkable.category)
      end
    end
  end

  def tariff_category_direction_icon(category)
    icon = if category.direction.inbound?
      "fa-arrow-left"
    elsif category.direction.outbound?
      "fa-arrow-right"
    end
    tag.i(class: "fa-solid #{icon}")
  end

  def group_collection_by(collection, &)
    collection.each_with_object(Hash.new { |h, k| h[k] = [] }) do |item, result|
      result[yield(item)] << item
    end.sort.to_h
  end
end

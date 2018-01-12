module Middleman::Svg::TransformPipeline::Transformations
  # Transformations are run in priority order, lowest number first:
  def self.built_in_transformations
    {
      id: { transform: IdAttribute, priority: 1 },
      desc: { transform: Description, priority: 2 },
      title: { transform: Title, priority: 3 },
      aria: { transform: AriaAttributes },
      aria_hidden: { transform: AriaHiddenAttribute },
      class: { transform: ClassAttribute },
      style: { transform: StyleAttribute },
      data: { transform: DataAttributes },
      height: { transform: Height },
      nocomment: { transform: NoComment },
      preserve_aspect_ratio: { transform: PreserveAspectRatio },
      size: { transform: Size },
      width: { transform: Width },
    }
  end

  def self.custom_transformations
    magnify_priorities(Middleman::Svg.configuration.custom_transformations)
  end

  def self.magnify_priorities(transforms)
    transforms.inject({}) do |output, (name, definition)|
      priority = definition.fetch(:priority, built_in_transformations.size)

      output[name] = definition.merge( { priority: magnify(priority) } )
      output
    end
  end

  def self.magnify(priority=0)
    (priority + 1) * built_in_transformations.size
  end

  def self.all_transformations
    in_priority_order(built_in_transformations.merge(custom_transformations))
  end

  def self.lookup(transform_params)
    all_transformations.map { |name, definition|
      value = params_with_defaults(transform_params)[name]
      definition.fetch(:transform, no_transform).create_with_value(value) if value
    }.compact
  end

  def self.in_priority_order(transforms)
    transforms.sort_by { |_, options| options.fetch(:priority, transforms.size) }
  end

  def self.params_with_defaults(params)
    without_empty_values(all_default_values.merge(params))
  end

  def self.without_empty_values(params)
    params.reject {|key, value| value.nil?}
  end

  def self.all_default_values
    custom_transformations
      .values
      .select {|opt| opt[:default_value] != nil}
      .map {|opt| [opt[:attribute], opt[:default_value]]}
      .inject({}) {|options, attrs| options.merge!(attrs[0] => attrs[1])}
  end

  def self.no_transform
    Middleman::Svg::TransformPipeline::Transformations::NullTransformation
  end
end

require 'middleman/svg/transform_pipeline/transformations/transformation'
require 'middleman/svg/transform_pipeline/transformations/no_comment'
require 'middleman/svg/transform_pipeline/transformations/class_attribute'
require 'middleman/svg/transform_pipeline/transformations/style_attribute'
require 'middleman/svg/transform_pipeline/transformations/title'
require 'middleman/svg/transform_pipeline/transformations/description'
require 'middleman/svg/transform_pipeline/transformations/size'
require 'middleman/svg/transform_pipeline/transformations/height'
require 'middleman/svg/transform_pipeline/transformations/width'
require 'middleman/svg/transform_pipeline/transformations/id_attribute'
require 'middleman/svg/transform_pipeline/transformations/data_attributes'
require 'middleman/svg/transform_pipeline/transformations/preserve_aspect_ratio'
require 'middleman/svg/transform_pipeline/transformations/aria_attributes'
require "middleman/svg/transform_pipeline/transformations/aria_hidden_attribute"
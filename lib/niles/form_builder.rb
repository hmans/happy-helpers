# currently untested, probably not working!
#
module Niles
  class FormBuilder
    attr_reader :helpers, :resource, :form_options

    def initialize(helpers, resource, form_options = {})
      @helpers = helpers
      @resource = resource
      @resource_name = resource.class.to_s.singularize.underscore
      @form_options = form_options
    end

    def input(name, options = {})
      name = name.to_s

      # Set default options
      options = {
        label: "%s:" % label_text(name),
        value: resource.send(name)
      }.merge(options)

      # FIXME
      options[:as] ||= case options[:value]
        when Date           then :date
        when DateTime, Time then :datetime
        else :text
      end

      # Set default options for the input field
      field_options = {
        name: "%s[%s]" % [@resource_name, name]
      }
      unless (placeholder = options.delete(:placeholder) || placeholder(name)).blank?
        field_options[:placeholder] = placeholder
      end

      # Set default options for the wrapper element
      wrapper_options = {
        class: "input #{options[:as]}"
      }
      wrapper_options[:class] << " with_error" if resource.errors[name].any?

      # Output wrapper tag with contents
      helpers.html_tag :div, wrapper_options do
        String.new.tap do |s|
          # Add label
          s << helpers.html_tag(:label) { options[:label] }

          # Add actual input field
          case options[:as].to_sym
          when :textarea
            s << helpers.html_tag(:textarea, field_options) { helpers.preserve(helpers.escape_html(options[:value])) }
          when :datetime
            s << helpers.date_time_select(field_options.delete(:name), value: options[:value])
          else
            s << helpers.html_tag(:input, field_options.merge(type: 'text', value: options[:value]))
          end

          # Add error message, if necessary
          if @resource.errors[name].any?
            s << helpers.html_tag(:div, :class => "error") { @resource.errors[name].first }
          end
        end
      end
    end

    def label_text(name)
      helpers.translate("forms.#{@resource_name}.labels.#{name}", :default => name.humanize)
    end

    def placeholder(name)
      helpers.translate("forms.#{@resource_name}.placeholders.#{name}", :default => "")
    end

    def submit(label = nil)
      label ||= (resource.new_record? ? 'Create' : 'Update')
      helpers.html_tag(:input, type: 'submit', value: label)
    end
  end
end

module Niles
  module Helpers
    module Forms
      def date_time_select(name, options = {})
        options = {
          :years => 1976..2012,
          :months => 1..12,
          :days => 1..31,
          :month_formatter => ->(i) { translate("date.month_names")[i] },
          :day_formatter   => ->(i) { "#{i}." },
          :value => Time.now
        }.merge(options)

        year_select = html_tag(:select, name: "#{name}[year]") do
          options[:years].map do |year|
            html_tag(:option, value: year, selected: year == options[:value].try(:year)) { year }
          end.join
        end

        month_select = html_tag(:select, name: "#{name}[month]") do
          options[:months].map do |month|
            html_tag(:option, value: month, selected: month == options[:value].try(:month)) { options[:month_formatter].call(month) }
          end.join
        end

        day_select = html_tag(:select, name: "#{name}[day]") do
          options[:days].map do |day|
            html_tag(:option, value: day, selected: day == options[:value].try(:day)) { options[:day_formatter].call(day) }
          end.join
        end

        hour_select = html_tag(:select, name: "#{name}[hour]") do
          (0..23).map do |hour|
            html_tag(:option, value: hour, selected: hour == options[:value].try(:hour)) { sprintf "%02d", hour }
          end.join
        end

        minute_select = html_tag(:select, name: "#{name}[minute]") do
          (0..59).map do |minute|
            html_tag(:option, value: minute, selected: minute == options[:value].try(:minute)) { sprintf "%02d", minute }
          end.join
        end

        "#{day_select} #{month_select} #{year_select} - #{hour_select} : #{minute_select} Uhr"
      end

      def form_for(resource, options = {}, &block)
        options = {
          action: resource.new_record? ? "/#{resource.class.to_s.tableize}" : "/#{resource.class.to_s.tableize}/#{resource.id}",
          method: 'post'
        }.merge(options)

        html_tag :form, options do
          capture do
            yield FormBuilder.new(self, resource, options)
          end
        end
      end

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
  end
end

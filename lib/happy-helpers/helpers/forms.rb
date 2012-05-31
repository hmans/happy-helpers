module HappyHelpers
  module Helpers
    module Forms
      def radio_buttons(name, options = {})
        "".tap do |s|
          options[:options].each do |option|
            if option.is_a?(Array)
              label = option[0]
              value = option[1]
            else
              label = option
              value = option
            end

            s << html_tag(:label) do
              html_tag(:input, :type => 'radio', :name => name, :value => value) + label
            end
          end
        end
      end

      def date_time_select_tag(name, value = nil, options = {})
        options = {
          :years => (Time.now.year - 10)..(Time.now.year + 10),
          :months => 1..12,
          :days => 1..31,
          :month_formatter => ->(i) { translate("date.month_names")[i] },
          :day_formatter   => ->(i) { "#{i}." }
        }.merge(options)
        value ||= Time.now

        year_select = html_tag(:select, :name => "#{name}[year]") do
          options[:years].map do |year|
            html_tag(:option, :value => year, :selected => year == value.try(:year)) { year }
          end.join
        end

        month_select = html_tag(:select, :name => "#{name}[month]") do
          options[:months].map do |month|
            html_tag(:option, :value => month, :selected => month == value.try(:month)) { options[:month_formatter].call(month) }
          end.join
        end

        day_select = html_tag(:select, :name => "#{name}[day]") do
          options[:days].map do |day|
            html_tag(:option, :value => day, :selected => day == value.try(:day)) { options[:day_formatter].call(day) }
          end.join
        end

        hour_select = html_tag(:select, :name => "#{name}[hour]") do
          (0..23).map do |hour|
            html_tag(:option, :value => hour, :selected => hour == value.try(:hour)) { sprintf "%02d", hour }
          end.join
        end

        minute_select = html_tag(:select, :name => "#{name}[minute]") do
          (0..59).map do |minute|
            html_tag(:option, :value => minute, :selected => minute == value.try(:min)) { sprintf "%02d", minute }
          end.join
        end

        "#{day_select} #{month_select} #{year_select} - #{hour_select} : #{minute_select} Uhr"
      end

      def checkbox_tag(name, value = false, options = {})
        "".tap do |s|
          s << html_tag(:input, :name => name, :type => 'hidden', :value => '0')
          s << html_tag(:input, :name => name, :type => 'checkbox', :value => '1', :checked => value ? true : false)
          s << html_tag(:label, :class => 'for-checkbox') { options[:text] || name }
        end
      end

      def form_for(resource, options = {}, &block)
        options = {
          :action => resource.new_record? ? "/#{resource.class.to_s.tableize}" : "/#{resource.class.to_s.tableize}/#{resource.id}",
          :method => 'post'
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
          value = resource.send(name)

          # Set default options
          options = {
            :label => "%s:" % label_text(name)
          }.merge(options)

          options[:as] ||= case options[:value]
            when Date           then :date
            when DateTime, Time then :datetime
            when Boolean, TrueClass, FalseClass then :checkbox
            else :text
          end

          # Set default options for the input field
          field_options = {
            :name => "%s[%s]" % [@resource_name, name]
          }
          unless (placeholder = options.delete(:placeholder) || placeholder(name)).blank?
            field_options[:placeholder] = placeholder
          end

          # Set default options for the wrapper element
          wrapper_options = {
            :class => "input #{options[:as]}"
          }
          wrapper_options[:class] << " with_error" if resource.errors[name].any?

          # Output wrapper tag with contents
          helpers.html_tag :div, wrapper_options do
            String.new.tap do |s|
              # Add actual input field
              case options.delete(:as).to_sym
              when :textarea
                s << helpers.html_tag(:label, :class => 'for-field') { options[:label] }
                s << helpers.html_tag(:textarea, field_options) { helpers.preserve(helpers.escape_html(value)) }
              when :datetime
                s << helpers.html_tag(:label, :class => 'for-field') { options[:label] }
                s << helpers.date_time_select_tag(field_options.delete(:name), value, options)
              when :radio
                s << helpers.radio_buttons(field_options.delete(:name), :options => (options.delete(:options) || ['Y', 'N']))
              when :checkbox
                s << helpers.checkbox_tag(field_options.delete(:name), value, options.merge(:text => options[:text] || label_text(name)))
              else
                s << helpers.html_tag(:label, :class => 'for-field') { options[:label] }
                s << helpers.html_tag(:input, field_options.merge(:type => 'text', :value => value))
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
          helpers.html_tag(:input, :type => 'submit', :value => label)
        end
      end
    end
  end
end

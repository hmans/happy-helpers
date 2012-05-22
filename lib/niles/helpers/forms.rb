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
    end
  end
end

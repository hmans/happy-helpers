module Niles
  module Helpers
    module Html
      def html_tag(name, options = nil, escape = true, &block)
        "<#{name} #{html_tag_attributes(options, escape) if options}#{block_given? ? ">#{yield if block_given?}</#{name}>" : " />"}"
      end

      def html_tag_attributes(options, escape = true)
        options.map do |k,v|
          if v
            v == true ? "#{k}" : "#{k}=\"#{ escape_html(v) }\""
          end
        end.compact.join(" ")
      end

      def escape_html(t)
        Rack::Utils.escape_html(t.to_s)
      end

      def preserve(t)
        t.chomp("\n").gsub(/\n/, '&#x000A;').gsub(/\r/, '')
      end

      def link_to(name, target, options = {})
        html_tag(:a, options.merge(href: url_for(target))) { name }
      end

      def url_for(what)
        case what
          when String then what
          when Symbol then "/#{what}"
          when Array  then target.map { |i| url_for i }.join
          else what.to_s
        end
      end

      def capture(*args, &block)
        # TODO: support more than just HAML. :P~
        capture_haml(*args, &block)
      end
    end
  end
end

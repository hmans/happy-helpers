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
    end
  end
end

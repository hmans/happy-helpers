require 'tilt'

module HappyHelpers
  module Templates
    def self.render(name, scope = nil, variables = {}, &block)
      load(name).render(scope, variables, &block)
    end

    def self.load(name)
      name = File.expand_path(name)

      if false # Freddie.env.production?
        @templates ||= {}
        @templates[name] ||= Tilt.new(name, :default_encoding => 'utf-8')
      else
        Tilt.new(name, :default_encoding => 'utf-8')
      end
    end
  end
end

# -*- encoding: utf-8 -*-

require 'i18n'

module HappyHelpers
  module Helpers
    module Numbers
      def currency(v, options = {})
        money = v.respond_to?(:to_money) ? v.to_money : Money.new(v * 100)
        money.format
      end
    end
  end
end

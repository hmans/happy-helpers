# -*- encoding: utf-8 -*-
require 'spec_helper'
require 'money'

Money.default_currency = 'EUR'

module HappyHelpers
  module Helpers
    describe Numbers do
      describe "#currency" do
        include Numbers

        it "formats the given numerical value as a currency string" do
          currency(1).should == "€1,00"
          currency(1234.567).should == "€1.234,57"
        end

        it "also accept string values" do
          currency("EUR 12,99").should == '€12,99'
        end

        it "knows how to deal with negative values" do
          currency(-1234.56).should == '€-1.234,56'
        end
      end
    end
  end
end

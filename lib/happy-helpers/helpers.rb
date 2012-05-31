require 'happy-helpers/helpers/html'
require 'happy-helpers/helpers/forms'
require 'happy-helpers/helpers/i18n'

module HappyHelpers
  module Helpers
    include Html
    include I18n
    include Forms
  end
end

# frozen_string_literal: true

require "edfize/color"
require "edfize/tests/result"
require "edfize/tests/runner"
require "edfize/tests/check_length"
require "edfize/tests/check_reserved_area"
require "edfize/tests/check_reserved_signal_areas"
require "edfize/tests/check_valid_date"

module Edfize
  module Tests
    extend CheckLength
    extend CheckReservedArea
    extend CheckReservedSignalAreas
    extend CheckValidDate
  end
end

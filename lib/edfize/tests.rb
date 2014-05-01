require 'edfize/tests/result'
require 'edfize/tests/runner'
require 'edfize/tests/check_length'
require 'edfize/tests/check_reserved_area'
require 'edfize/tests/check_reserved_signal_areas'

module Edfize
  module Tests
    extend CheckLength
    extend CheckReservedArea
    extend CheckReservedSignalAreas
  end
end

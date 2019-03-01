# frozen_string_literal: true

module Edfize
  module Tests
    # This test checks that the reserved area in the header is blank
    module CheckReservedArea
      def test_reserved_area_blank(runner)
        result           = Result.new
        result.passes    = (runner.edf.reserved == " " * Edf::RESERVED_SIZE)
        result.pass_fail = "  #{result.passes ? "PASS" : "FAIL"}".send(result.passes ? :green : :red) + " Reserved Area Blank"
        result.expected  = "    Expected : #{(" " * Edf::RESERVED_SIZE).inspect}"
        result.actual    = "    Actual   : #{runner.edf.reserved.to_s.inspect}"
        result
      end
    end
  end
end

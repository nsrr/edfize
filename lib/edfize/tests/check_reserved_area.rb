module Edfize
  module Tests
    module CheckReservedArea
      # This test checks that the reserved area in the header is blank
      def test_reserved_area_blank(runner)
        result           = Result.new
        result.passes    = (runner.edf.reserved == ' ' * Edf::RESERVED_SIZE)
        result.pass_fail = "  #{result.passes ? 'PASS' : 'FAIL'}".colorize( result.passes ? :green : :red ) + " Reserved Area Blank"
        result.expected  = "    Expected : #{(' ' * Edf::RESERVED_SIZE).inspect}"
        result.actual    = "    Actual   : #{runner.edf.reserved.to_s.inspect}"
        result
      end
    end
  end
end

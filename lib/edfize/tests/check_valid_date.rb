# frozen_string_literal: true

module Edfize
  module Tests
    # This test checks that the date is valid
    module CheckValidDate
      def test_valid_date(runner)
        result = Result.new
        result.passes = !runner.edf.start_date.nil?
        result.pass_fail = pass_fail(result.passes, 'Valid Date')
        result.expected  = '    Expected : dd.mm.yy'
        result.actual    = "    Actual   : #{runner.edf.start_date_of_recording}"
        result
      end

      def pass_fail(passes, message)
        if passes
          '  PASS'.colorize(:green) + " #{message}"
        else
          '  FAIL'.colorize(:red) + " #{message}"
        end
      end
    end
  end
end

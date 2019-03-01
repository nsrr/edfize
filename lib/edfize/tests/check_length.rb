# frozen_string_literal: true

module Edfize
  module Tests
    module CheckLength
      # This test checks that the length calculated from the EDF header matches
      # the total length of the file
      def test_expected_length(runner)
        result = Result.new
        result.passes = (runner.edf.expected_edf_size == runner.edf.edf_size)
        result.pass_fail = "  #{result.passes ? "PASS" : "FAIL"}".send(result.passes ? :green : :red) + " Expected File Size"
        result.expected  = "    Expected : #{runner.edf.expected_edf_size} bytes"
        result.actual    = "    Actual   : #{runner.edf.edf_size} bytes"
        result
      end
    end
  end
end

module Edfize
  module Tests
    # This test checks that the length calculated from the EDF header matches
    # the total length of the file
    def self.test_expected_length(edf)
      passes = (edf.expected_total_size == edf.total_size)
      puts "  #{passes ? 'PASS' : 'FAIL'}".colorize( passes ? :green : :red ) + " Expected File Size"
      unless passes or not verbose
        puts "    Expected : #{edf.expected_total_size} bytes"
        puts "    Actual   : #{edf.total_size} bytes"
      end
      passes
    end
  end
end

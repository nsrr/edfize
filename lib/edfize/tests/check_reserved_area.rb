module Edfize
  module Tests
    # This test checks that the reserved area in the header is blank
    def self.test_reserved_area_blank(edf)
      passes = (edf.reserved.to_s.strip == '')
      puts "  #{passes ? 'PASS' : 'FAIL'}".colorize( passes ? :green : :red ) + " Reserved Area Blank"
      unless passes or not verbose
        puts "    Expected : '#{' ' * 32}'"
        puts "    Actual   : #{edf.reserved.to_s}"
      end
      passes
    end
  end
end

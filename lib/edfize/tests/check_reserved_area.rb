module Edfize
  module Tests
    # This test checks that the reserved area in the header is blank
    def self.test_reserved_area_blank(edf)
      passes = (edf.reserved == ' ' * Edf::RESERVED_SIZE)
      puts "  #{passes ? 'PASS' : 'FAIL'}".colorize( passes ? :green : :red ) + " Reserved Area Blank"
      unless passes or not verbose
        puts "    Expected : #{(' ' * Edf::RESERVED_SIZE).inspect}"
        puts "    Actual   : #{edf.reserved.to_s.inspect}"
      end
      passes
    end
  end
end

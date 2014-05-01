module Edfize
  module Tests
    # This test checks that the reserved areas in the signal headers are blank
    def self.test_reserved_signal_areas_blank(edf)
      reserved_areas = edf.signals.collect(&:reserved_area)
      passes = (reserved_areas.reject{|r| r.to_s.strip == ''}.count == 0)
      puts "  #{passes ? 'PASS' : 'FAIL'}".colorize( passes ? :green : :red ) + " Signal Reserved Area Blank"
      unless passes or not verbose
        puts "    Expected : #{[''] * edf.signals.count}"
        puts "    Actual   : #{reserved_areas}"
      end
      passes
    end
  end
end

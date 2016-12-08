# frozen_string_literal: true

module Edfize
  module Tests
    # Runs a series of tests on an EDF
    class Runner
      attr_reader :tests_run, :tests_failed, :edf, :verbose, :show_passing

      TESTS = %w(expected_length reserved_area_blank valid_date) # reserved_signal_areas_blank

      def initialize(edf, argv)
        @tests_run = 0
        @tests_failed = 0
        @edf = edf
        @verbose = argv.include?('--quiet') ? false : true
        @show_passing = argv.include?('--failing') ? false : true
      end

      def run_tests
        results = []

        TESTS.each do |test_name|
          result = Edfize::Tests.send("test_#{test_name}", self)
          @tests_failed += 1 unless result.passes
          @tests_run += 1
          results << result
        end

        puts "\n#{@edf.filename}" if results.reject(&:passes).count > 0 || @show_passing
        results.each do |result|
          print_result(result)
        end
      end

      def print_result(result)
        if show_passing || !result.passes
          puts result.pass_fail
          unless result.passes || !verbose
            puts result.expected
            puts result.actual
          end
        end
      end
    end
  end
end

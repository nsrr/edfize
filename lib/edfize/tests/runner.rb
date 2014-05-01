module Edfize
  module Tests
    class Runner
      attr_reader :tests_run, :tests_failed, :edf, :verbose, :show_passing

      TESTS = %w( expected_length reserved_area_blank reserved_signal_areas_blank )

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

        puts "\n#{@edf.filename}" if results.reject{|r| r.passes}.count > 0 or @show_passing
        results.each do |result|
          print_result(result)
        end

        # test_expected_length(edf) ? nil : failure_count += 1
        # test_count += 1

        # test_reserved_area_blank(edf) ? nil : failure_count += 1
        # test_count += 1

        # test_reserved_signal_areas_blank(edf) ? nil : failure_count += 1
        # test_count += 1

        # [test_count, failure_count]
      end

      def print_result(result)
        if self.show_passing or !result.passes
          puts result.pass_fail
          unless result.passes or not self.verbose
            puts result.expected
            puts result.actual
          end
        end
      end
    end
  end
end

require 'edfize/tests/check_length'

module Edfize
  module Tests
    def self.verbose
      true
    end

    def self.run(edf)
      puts "\n#{edf.filename}"

      failure_count = 0
      test_count = 0

      test_expected_length(edf) ? nil : failure_count += 1
      test_count += 1

      [test_count, failure_count]
    end
  end
end

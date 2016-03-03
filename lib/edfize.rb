# frozen_string_literal: true

require 'edfize/edf'
require 'edfize/tests'
require 'edfize/version'

require 'colorize'

# Loads EDFs, prints information, runs tests
module Edfize
  def self.launch(argv)
    case argv.first.to_s.scan(/\w/).first
    when 'v'
      version
    when 'c', 't'
      check(argv[1..-1])
    when 'r'
      print_headers
    else
      help
    end
  end

  def self.print_headers
    puts '----------------'
    edfs_in_current_directory_and_subdirectories.each do |edf_file_name|
      edf = Edfize::Edf.new(edf_file_name)
      edf.print_header
      puts '----------------'
    end
  end

  def self.version
    puts "Edfize #{Edfize::VERSION::STRING}"
  end

  def self.check(argv)
    test_start_time = Time.now
    edf_count = edfs_in_current_directory_and_subdirectories.count
    test_count = 0
    failure_count = 0
    puts "Started\n"
    edfs_in_current_directory_and_subdirectories.each do |edf_file_name|
      edf = Edfize::Edf.new(edf_file_name)
      runner = Edfize::Tests::Runner.new(edf, argv)
      runner.run_tests
      test_count += runner.tests_run
      failure_count += runner.tests_failed
    end
    puts "\nFinished in #{Time.now - test_start_time}s"
    puts "#{edf_count} EDF#{'s' unless edf_count == 1}, #{test_count} test#{'s' unless test_count == 1}, " + "#{failure_count} failure#{'s' unless failure_count == 1}".colorize(failure_count == 0 ? :green : :red)
  end

  def self.help
    help_message = <<-EOT
Usage: edfize COMMAND [ARGS]

The most common edfize commands are:
  [t]est            Check EDFs in directory and subdirectories
    --failing       Only display failing tests
    --quiet         Suppress failing test descriptions
  [r]un             Print EDF header information
  [h]elp            Show edfize command documentation
  [v]ersion         Returns the version of Edfize

Commands can be referenced by the first letter:
  Ex: `edfize t`, for test

EOT
    puts help_message
  end

  def self.edfs_in_current_directory_and_subdirectories
    Dir.glob('**/*.edf')
  end
end

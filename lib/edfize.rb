require 'edfize/edf'
require 'edfize/version'

module Edfize
  def self.launch(argv)
    case argv.first.to_s.scan(/\w/).first
    when 'v'
      version
    when 'c', 't'
      check
    when 'r'
      print_headers
    else
      help
    end
  end

  def self.print_headers
    puts "----------------"
    edfs_in_current_directory.each do |edf_file_name|
      edf = Edfize::Edf.new(edf_file_name)
      edf.print_header
      puts "----------------"
    end
  end

  def self.version
    puts "Edfize #{Edfize::VERSION::STRING}"
  end

  def self.check
    edf_count = edfs_in_current_directory.count
    puts "Checking #{edf_count} EDF#{'s' unless edf_count == 1}"
  end

  def self.help
    help_message = <<-EOT
Usage: edfize COMMAND [ARGS]

The most common edfize commands are:
  [c]heck           Check EDFs in current directory for errors
  [t]est            Same as [c]heck
  [h]elp            Show edfize command-line documentation
  [v]ersion         Returns the version of Edfize

Commands can be referenced by the first letter:
  Ex: `edfize t`, for test

EOT
    puts help_message
  end

  def self.edfs_in_current_directory
    Dir.glob('*.edf')
  end
end

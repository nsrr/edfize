# Edfize

[![Build Status](https://travis-ci.org/sleepepi/edfize.svg?branch=master)](https://travis-ci.org/sleepepi/edfize)
[![Dependency Status](https://gemnasium.com/sleepepi/edfize.svg)](https://gemnasium.com/sleepepi/edfize)
[![Code Climate](https://codeclimate.com/github/sleepepi/edfize.png)](https://codeclimate.com/github/sleepepi/edfize)

Ruby gem used to load, validate, and parse European Data Format files. Used for batch testing EDFs for errors. Ruby 2.0+ compatible.

## Installation

Add this line to your application's Gemfile:

    gem 'edfize'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install edfize

## Usage

### Validate EDFs

Use `edfize test` to test that EDFs stored in the current directory have a valid format.

    cd <edf-directory>
    edfize test

A list of validations performed is:

- **Expected Length Check**: Compares the calculated size of the file based on signal sizes defined in the header with the actual file size. A failure may indicate corruption in the header (if the expected is less than the actual file size), or a partial/truncated file (if the expected is more than the actual file size).
- **Reserved Area Checks**: Check that reserved areas are blank. Non-blank reserved areas can indicate a sign of header or EDF file corruption.

Flags that can be added to the `test` command include:

- `--failing`: Only display EDFs with failing tests
- `--quiet`: Suppress detailed failure descriptions that show the expected versus the actual result of the test

### Print Signal Header information

Use `edfize run` to print out signal header information for each EDF in the current directory.

    cd <edf-directory>
    edfize run

### View A List of All Available Commands for Edfize

Use `edfize help` to list available commands and descriptions for Edfize.

    edfize help

### View Current Version of Edfize

Use `edfize version` to check the version of Edfize.

    edfize version

### Upgrade Edfize

Use `gem install edfize` to update Edfize to the latest stable

Use `gem install edfize --pre` to update Edfize to the latest prerelease

### Example of how to Load and Analyze EDFs in a Ruby Script

The following Ruby file demonstrates how to make use of the Edfize gem to load EDF signals into arrays for analysis.

`tutorial_01_load_edf_and_signals.rb`
```ruby
# Tutorial 01 - Load EDF and Signals
#
#   gem install edfize
#
#   ruby tutorial_01_load_edf_and_signals.rb
#
# The EDF exists at:
#
#    https://sleepdata.org/datasets/shhs/files/edfs/shhs1?f=shhs1-200001.edf
#

require 'rubygems'
require 'edfize'

# Loads the file and reads the EDF Header
edf = Edfize::Edf.new('shhs1-200001.edf')

# Loads the data section of the EDF into Signal objects
edf.load_signals

# Print out information on the signals
puts "EDF #{edf.filename} contains the following #{edf.signals.count} signal#{'s' unless edf.signals.count == 1}:\n\n"

edf.signals.each do |signal|
  puts "Signal"
  puts "  Label                  : #{signal.label}"
  puts "  Samples Per Data Record: #{signal.samples_per_data_record}"
  puts "  First 10 Samples       : #{(signal.samples[0..10] + ['...']).inspect}\n\n"
end
```

When run, the code above will output the following:

```console
EDF shhs1-200001.edf contains the following 14 signals:

Signal
  Label                  : SaO2
  Samples Per Data Record: 1
  First 10 Samples       : [29695, 29695, 29695, 29695, 29695, 29695, 29695, 29695, 28927, 28927, 28927, "..."]

Signal
  Label                  : H.R.
  Samples Per Data Record: 1
  First 10 Samples       : [-12493, -12493, -12493, -12697, -12697, -12697, -13107, -13107, -13107, -13107, -13107, "..."]

Signal
  Label                  : EEG(sec)
  Samples Per Data Record: 125
  First 10 Samples       : [-5, -13, -2, -13, -23, 1, 21, -9, 6, -17, 6, "..."]

Signal
  Label                  : ECG
  Samples Per Data Record: 125
  First 10 Samples       : [3, 7, -10, 0, 5, 4, 0, 3, 11, -12, -3, "..."]

Signal
  Label                  : EMG
  Samples Per Data Record: 125
  First 10 Samples       : [51, 9, -48, 84, 10, -23, 20, -10, 58, 2, 26, "..."]

Signal
  Label                  : EOG(L)
  Samples Per Data Record: 50
  First 10 Samples       : [29, 3, -127, 15, -67, 47, -3, -33, -25, 16, 28, "..."]

Signal
  Label                  : EOG(R)
  Samples Per Data Record: 50
  First 10 Samples       : [12, 25, 127, -106, 59, -3, 9, 7, 20, 7, -7, "..."]

Signal
  Label                  : EEG
  Samples Per Data Record: 125
  First 10 Samples       : [-3, 31, 65, 4, 52, 12, -2, 21, -26, 34, -9, "..."]

Signal
  Label                  : THOR RES
  Samples Per Data Record: 10
  First 10 Samples       : [-27, 17, -25, -57, 18, -24, 6, 32, 38, -21, 41, "..."]

Signal
  Label                  : ABDO RES
  Samples Per Data Record: 10
  First 10 Samples       : [-40, 34, -2, -28, 68, -117, -20, -24, 5, -27, 67, "..."]

Signal
  Label                  : POSITION
  Samples Per Data Record: 1
  First 10 Samples       : [2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, "..."]

Signal
  Label                  : LIGHT
  Samples Per Data Record: 1
  First 10 Samples       : [1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, "..."]

Signal
  Label                  : NEW AIR
  Samples Per Data Record: 10
  First 10 Samples       : [6, 7, 3, 3, 7, 3, 6, 0, 5, 5, 9, "..."]

Signal
  Label                  : OX stat
  Samples Per Data Record: 1
  First 10 Samples       : [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 2, "..."]
```

## Contributing

1. Fork it ( https://github.com/sleepepi/edfize/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

require 'edfize/signal'

module Edfize
  class Edf
    # EDF File Path
    attr_reader   :filename

    # Header Information
    attr_reader  :version
    attr_reader  :local_patient_identification
    attr_reader  :local_recording_identification
    attr_reader  :start_date_of_recording
    attr_reader  :start_time_of_recording
    attr_reader  :number_of_bytes_in_header
    attr_reader  :reserved
    attr_reader  :number_of_data_records
    attr_reader  :duration_of_a_data_record
    attr_reader  :number_of_signals

    attr_accessor :signals

    HEADER_CONFIG = {
      version:                        { size:  8, after_read: :to_i,  name: 'Version' },
      local_patient_identification:   { size: 80, after_read: :strip, name: 'Local Patient Identification' },
      local_recording_identification: { size: 80, after_read: :strip, name: 'Local Recording Identification' },
      start_date_of_recording:        { size:  8,                     name: 'Start Date of Recording', description: '(dd.mm.yy)' },
      start_time_of_recording:        { size:  8,                     name: 'Start Time of Recording', description: '(hh.mm.ss)'},
      number_of_bytes_in_header:      { size:  8, after_read: :to_i,  name: 'Number of Bytes in Header' },
      reserved:                       { size: 44,                     name: 'Reserved' },
      number_of_data_records:         { size:  8, after_read: :to_i,  name: 'Number of Data Records' },
      duration_of_a_data_record:      { size:  8, after_read: :to_i,  name: 'Duration of a Data Record', units: 'second' },
      number_of_signals:              { size:  4, after_read: :to_i,  name: 'Number of Signals' }
    }

    HEADER_OFFSET = HEADER_CONFIG.collect{|k,h| h[:size]}.inject(:+)

    SIZE_OF_SAMPLE_IN_BYTES = 2

    # Used by tests
    RESERVED_SIZE = HEADER_CONFIG[:reserved][:size]

    def initialize(filename)
      @filename = filename
      @signals = []

      read_header

      # Other
      signal_labels
      transducer_types
      physical_dimensions
      physical_minimums
      physical_maximums
      digital_minimums
      digital_maximums
      prefilterings
      samples_per_data_records
      reserved_areas
    end

    def load_signals
      get_data_records
    end

    def size_of_header
      HEADER_OFFSET + ns * (16 + 80 + 8 + 8 + 8 + 8 + 8 + 80 + 8 + 32)
    end

    def expected_size_of_header
      @number_of_bytes_in_header
    end

    # Total File Size In Bytes
    def edf_size
      File.size(@filename)
    end

    # Data Section Size In Bytes
    def expected_data_size
      @signals.collect(&:samples_per_data_record).inject(:+).to_i * @number_of_data_records * SIZE_OF_SAMPLE_IN_BYTES
    end

    def expected_edf_size
      expected_data_size + size_of_header
    end

    def section_value_to_string(section)
      self.instance_variable_get("@#{section}").to_s
    end

    def section_units(section)
      units = HEADER_CONFIG[section][:units].to_s
      result = if units == ''
        ''
      else
        " #{units}" + (self.instance_variable_get("@#{section}") == 1 ? '' : 's')
      end
      result
    end

    def section_description(section)
      description = HEADER_CONFIG[section][:description].to_s
      result = if description == ''
        ''
      else
        " #{description}"
      end
      result
    end

    def print_header
      puts "\nEDF                            : #{@filename}"
      puts "Total File Size                : #{edf_size} bytes"
      puts "\nHeader Information"
      HEADER_CONFIG.each do |section, hash|
        puts "#{hash[:name]}#{' '*(31 - hash[:name].size)}: " + section_value_to_string(section) + section_units(section) + section_description(section)
      end
      puts "\nSignal Information"
      signals.each_with_index do |signal, index|
        puts "\n  Position                     : #{index + 1}"
        puts "  Label                        : #{signal.label}"
        puts "  Physical Dimension           : #{signal.physical_dimension}"
        puts "  Transducer Type              : #{signal.transducer_type}"
        puts "  Physical Minimum             : #{signal.physical_minimum}"
        puts "  Physical Maximum             : #{signal.physical_maximum}"
        puts "  Digital Minimum              : #{signal.digital_minimum}"
        puts "  Digital Maximum              : #{signal.digital_maximum}"
        puts "  Prefiltering                 : #{signal.prefiltering}"
        puts "  Samples Per Data Record      : #{signal.samples_per_data_record}"
        puts "  Reserved Area                : '#{signal.reserved_area}'"
      end
      puts "\nGeneral Information"
      puts "Size of Header (bytes)         : #{size_of_header}"
      puts "Size of Data   (bytes)         : #{data_size}"
      puts "Total Size     (bytes)         : #{edf_size}"

      puts "Expected Size of Header (bytes): #{expected_size_of_header}"
      puts "Expected Size of Data   (bytes): #{expected_data_size}"
      puts "Expected Total Size     (bytes): #{expected_edf_size}"
    end

    protected

    def read_header
      read_header_section(:version)
      read_header_section(:local_patient_identification)
      read_header_section(:local_recording_identification)
      read_header_section(:start_date_of_recording)
      read_header_section(:start_time_of_recording)
      read_header_section(:number_of_bytes_in_header)
      read_header_section(:reserved)
      read_header_section(:number_of_data_records)
      read_header_section(:duration_of_a_data_record)
      read_header_section(:number_of_signals)
    end

    def read_header_section(section)
      result = IO.binread(@filename, HEADER_CONFIG[section][:size], compute_offset(section) )
      result = result.to_s.send(HEADER_CONFIG[section][:after_read]) unless HEADER_CONFIG[section][:after_read].to_s == ''
      self.instance_variable_set("@#{section}", result)
    end

    def compute_offset(section)
      offset = 0
      HEADER_CONFIG.each do |key, hash|
        break if key == section
        offset += hash[:size]
      end
      offset
    end

    def ns
      @number_of_signals
    end

    # ns * 16 ascii : ns * label (e.g. EEG Fpz-Cz or Body temp) (mind item 9 of the additional EDF+ specs)
    def signal_labels
      offset = HEADER_OFFSET
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].label = IO.binread(@filename, 16, offset+(signal_number*16))
      end
    end

    # ns * 80 ascii : ns * transducer type (e.g. AgAgCl electrode)
    def transducer_types
      offset = HEADER_OFFSET + ns * 16
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].transducer_type = IO.binread(@filename, 80, offset+(signal_number*80))
      end
    end

    # ns * 8 ascii : ns * physical dimension (e.g. uV or degreeC)
    def physical_dimensions
      offset = HEADER_OFFSET + ns * (16 + 80)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].physical_dimension = IO.binread(@filename, 8, offset+(signal_number*8))
      end
    end

    # ns * 8 ascii : ns * physical minimum (e.g. -500 or 34)
    def physical_minimums
      offset = HEADER_OFFSET + ns * (16 + 80 + 8)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].physical_minimum = IO.binread(@filename, 8, offset+(signal_number*8))
      end
    end

    # ns * 8 ascii : ns * physical maximum (e.g. 500 or 40)
    def physical_maximums
      offset = HEADER_OFFSET + ns * (16 + 80 + 8 + 8)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].physical_maximum = IO.binread(@filename, 8, offset+(signal_number*8))
      end
    end

    # ns * 8 ascii : ns * digital minimum (e.g. -2048)
    def digital_minimums
      offset = HEADER_OFFSET + ns * (16 + 80 + 8 + 8 + 8)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].digital_minimum = IO.binread(@filename, 8, offset+(signal_number*8))
      end
    end

    # ns * 8 ascii : ns * digital maximum (e.g. 2047)
    def digital_maximums
      offset = HEADER_OFFSET + ns * (16 + 80 + 8 + 8 + 8 + 8)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].digital_maximum = IO.binread(@filename, 8, offset+(signal_number*8))
      end
    end

    # ns * 80 ascii : ns * prefiltering (e.g. HP:0.1Hz LP:75Hz)
    def prefilterings
      offset = HEADER_OFFSET + ns * (16 + 80 + 8 + 8 + 8 + 8 + 8)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].prefiltering = IO.binread(@filename, 80, offset+(signal_number*80))
      end
    end

    # ns * 8 ascii : ns * nr of samples in each data record
    def samples_per_data_records
      offset = HEADER_OFFSET + ns * (16 + 80 + 8 + 8 + 8 + 8 + 8 + 80)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].samples_per_data_record = IO.binread(@filename, 8, offset+(signal_number*8)).to_i
        @signals[signal_number].samples = Array.new(@signals[signal_number].samples_per_data_record, 0)
      end
    end

    # ns * 32 ascii : ns * reserved
    def reserved_areas
      offset = HEADER_OFFSET + ns * (16 + 80 + 8 + 8 + 8 + 8 + 8 + 80 + 8)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].reserved_area = IO.binread(@filename, 32, offset+(signal_number*32))
      end
    end


    #
    def get_data_records
      current_read_offset = size_of_header
      (0..@number_of_data_records-1).to_a.each do |data_record_index|
        @signals.each do |signal|
          # 16-bit signed integer size = 2 Bytes = 2 ASCII characters
          read_size = signal.samples_per_data_record * SIZE_OF_SAMPLE_IN_BYTES
          signal.samples[data_record_index..data_record_index+signal.samples_per_data_record] = IO.binread(@filename, read_size, current_read_offset).unpack('s*')
          current_read_offset += read_size
        end
      end
    end

    def data_size
      IO.binread(@filename, nil, size_of_header).size
    end
  end
end

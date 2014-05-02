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
      read_signal_header
    end

    def load_signals
      get_data_records
    end

    def size_of_header
      HEADER_OFFSET + ns * Signal::SIGNAL_CONFIG.collect{|k,h| h[:size]}.inject(:+)
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
        signal.print_header
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
      HEADER_CONFIG.keys.each do |section|
        read_header_section(section)
      end
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

    def create_signals
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
      end
    end

    def read_signal_header
      create_signals
      Signal::SIGNAL_CONFIG.keys.each do |section|
        read_signal_header_section(section)
      end
    end

    def compute_signal_offset(section)
      offset = 0
      Signal::SIGNAL_CONFIG.each do |key, hash|
        break if key == section
        offset += hash[:size]
      end
      offset
    end

    def read_signal_header_section(section)
      offset = HEADER_OFFSET + ns * compute_signal_offset(section)
      (0..ns-1).to_a.each do |signal_number|
        section_size = Signal::SIGNAL_CONFIG[section][:size]
        result = IO.binread(@filename, section_size, offset+(signal_number*section_size))
        result = result.to_s.send(Signal::SIGNAL_CONFIG[section][:after_read]) unless Signal::SIGNAL_CONFIG[section][:after_read].to_s == ''
        @signals[signal_number].send("#{section}=", result)
      end
    end

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

require 'edfize/signal'

module Edfize
  class Edf
    attr_reader   :filename

    attr_reader   :reserved               # 44 bytes - ASCII
    attr_reader   :number_of_data_records #  8 bytes - ASCII

    attr_accessor :signals

    RESERVED_SIZE = 44



    HEADER_OFFSET = 256
    SIZE_OF_SAMPLE_IN_BYTES = 2

    def initialize(filename)
      @filename = filename
      @signals = []

      read_header

      # Other
      get_number_of_data_records
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
      256 + (ns * 256)
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

    def print_header
      puts "\nEDF                            : #{@filename}"
      puts "Total File Size                : #{edf_size} bytes"
      puts "\nHeader Information"
      puts "Version                        : #{header_version}"
      puts "Local Patient Identification   : #{header_local_patient_identification}"
      puts "Local Recording Identification : #{header_local_recording_identification}"
      puts "Start Date of Recording        : #{header_start_date_of_recording} (dd.mm.yy)"
      puts "Start Time of Recording        : #{header_start_time_of_recording} (hh.mm.ss)"
      puts "Reserved                       : '#{@reserved}'"
      puts "Number of Data Records         : #{number_of_data_records}"
      puts "Duration of a Data Record      : #{duration_of_a_data_record.to_i} second#{'s' unless duration_of_a_data_record.to_i == 1}"
      puts "Number of Signals (NS)         : #{number_of_signals}"
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
      read_reserved
    end

    def header_version
      IO.binread(@filename, 8)
    end

    # 80 ascii : local patient identification (mind item 3 of the additional EDF+ specs)
    def header_local_patient_identification
      IO.binread(@filename, 80, 8)
    end

    # 80 ascii : local recording identification (mind item 4 of the additional EDF+ specs)
    def header_local_recording_identification
      IO.binread(@filename, 80, 88)
    end

    # 8 ascii : startdate of recording (dd.mm.yy) (mind item 2 of the additional EDF+ specs)
    def header_start_date_of_recording
      IO.binread(@filename, 8, 168)
    end

    # 8 ascii : starttime of recording (hh.mm.ss)
    def header_start_time_of_recording
      IO.binread(@filename, 8, 176)
    end

    # 8 ascii : number of bytes in header record
    def number_of_bytes_in_header
      IO.binread(@filename, 8, 184)
    end

    # 44 ascii : reserved
    def read_reserved
      @reserved = IO.binread(@filename, RESERVED_SIZE, 192)
    end

    # 8 ascii : number of data records (-1 if unknown, obey item 10 of the additional EDF+ specs)
    def get_number_of_data_records
      @number_of_data_records = IO.binread(@filename, 8, RESERVED_SIZE + 192).to_i
    end

    # 8 ascii : duration of a data record, in seconds
    def duration_of_a_data_record
      IO.binread(@filename, 8, 244)
    end

    # 4 ascii : number of signals (ns) in data record
    def number_of_signals
      IO.binread(@filename, 4, 252)
    end

    def ns
      Integer(self.number_of_signals) rescue 0
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

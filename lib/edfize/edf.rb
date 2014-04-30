require 'edfize/signal'

module Edfize
  class Edf
    attr_reader :signals

    HEADER_OFFSET = 256

    def initialize(filename)
      @filename = filename
      @signals = []
      signal_labels
      transducer_types
      physical_dimensions
      physical_minimums
      physical_maximums
      digital_minimums
      digital_maximums
      prefilterings
      samples_in_data_records
      reserved_areas
    end

    def size
      File.size(@filename)
    end

    def print_header
      puts @filename
      puts "#{size} bytes (Total File Size)"
      puts "'#{header_version}' (0)"
      puts "'#{header_local_patient_identification}' (local patient identification)"
      puts "'#{header_local_recording_identification}' (local recording indentification)"
      puts "'#{header_start_date_of_recording}' (dd.mm.yy start date of recording)"
      puts "'#{header_start_time_of_recording}' (hh.mm.ss start time of recording)"
      # puts "--- RESERVED"
      puts "'#{number_of_data_records}' seconds (number of data records, -1 if unknown)"
      puts "'#{duration_of_a_data_record}' seconds (duration of a data record)"
      puts "'#{number_of_signals}' number of signals (ns) in data record"
      signals.each_with_index do |signal, index|
        puts "'#{signal.label}' (signal[#{index+1}] label)"
        puts "'#{signal.physical_dimension}' (signal[#{index+1}] physical_dimension)"
        puts "'#{signal.transducer_type}' (signal[#{index+1}] transducer_type)"
        puts "'#{signal.physical_minimum}' (signal[#{index+1}] physical_minimum)"
        puts "'#{signal.physical_maximum}' (signal[#{index+1}] physical_maximum)"
        puts "'#{signal.digital_minimum}' (signal[#{index+1}] digital_minimum)"
        puts "'#{signal.digital_maximum}' (signal[#{index+1}] digital_maximum)"
        puts "'#{signal.prefiltering}' (signal[#{index+1}] prefiltering)"
        puts "'#{signal.samples_in_data_record}' (signal[#{index+1}] samples_in_data_record)"
        puts "'#{signal.reserved_area}' (signal[#{index+1}] reserved_area)"
      end
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
    # def reserved
    #   IO.binread(@filename, 44, 192)
    # end

    # 8 ascii : number of data records (-1 if unknown, obey item 10 of the additional EDF+ specs)
    def number_of_data_records
      IO.binread(@filename, 8, 236)
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
    def samples_in_data_records
      offset = HEADER_OFFSET + ns * (16 + 80 + 8 + 8 + 8 + 8 + 8 + 80)
      (0..ns-1).to_a.each do |signal_number|
        @signals[signal_number] ||= Signal.new()
        @signals[signal_number].samples_in_data_record = IO.binread(@filename, 8, offset+(signal_number*8))
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
  end
end

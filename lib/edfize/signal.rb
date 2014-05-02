module Edfize
  class Signal
    attr_accessor :label, :transducer_type, :physical_dimension,
                  :physical_minimum, :physical_maximum,
                  :digital_minimum, :digital_maximum,
                  :prefiltering, :samples_per_data_record,
                  :reserved_area, :samples

    SIGNAL_CONFIG = {
      label:                   { size: 16, after_read: :strip, name: 'Label' },
      transducer_type:         { size: 80, after_read: :strip, name: 'Transducer Type' },
      physical_dimension:      { size:  8, after_read: :strip, name: 'Physical Dimension' },
      physical_minimum:        { size:  8, after_read: :to_f,  name: 'Physical Minimum' },
      physical_maximum:        { size:  8, after_read: :to_f,  name: 'Physical Maximum' },
      digital_minimum:         { size:  8, after_read: :to_i,  name: 'Digital Minimum' },
      digital_maximum:         { size:  8, after_read: :to_i,  name: 'Digital Maximum' },
      prefiltering:            { size: 80, after_read: :strip, name: 'Prefiltering' },
      samples_per_data_record: { size:  8, after_read: :to_i,  name: 'Samples Per Data Record' },
      reserved_area:           { size: 32,                     name: 'Reserved Area' }
    }

    def initialize
      @samples = []
    end

    def print_header
      SIGNAL_CONFIG.each do |section, hash|
        puts "  #{hash[:name]}#{' '*(29 - hash[:name].size)}: " + self.send(section).to_s
      end
    end

  end
end

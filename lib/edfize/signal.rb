module Edfize
  class Signal
    attr_accessor :label, :transducer_type, :physical_dimension,
                  :physical_minimum, :physical_maximum,
                  :digital_minimum, :digital_maximum,
                  :prefiltering, :samples_per_data_record,
                  :reserved_area, :samples
  end
end

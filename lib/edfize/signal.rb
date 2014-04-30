module Edfize
  class Signal
    attr_accessor :label, :transducer_type, :physical_dimension, :physical_minimum, :physical_maximum,
                  :digital_minimum, :digital_maximum, :prefiltering, :samples_in_data_record, :reserved_area

    def initialize
      @label = ''
      @physical_dimension = ''
      @transducer_type = ''
      @physical_minimum = ''
      @physical_maximum = ''
      @digital_minimum = ''
      @digital_maximum = ''
      @prefiltering = ''
      @samples_in_data_record = ''
      @reserved_area = ''
    end

  end
end

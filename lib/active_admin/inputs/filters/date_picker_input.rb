module ActiveAdmin
  module Inputs
    module Filters
      class DatePickerInput < ::Formtastic::Inputs::DatePickerInput
        include Base

        def input_html_options
          super.merge(class: "datepicker form-control dpd")
        end
      end
    end
  end
end

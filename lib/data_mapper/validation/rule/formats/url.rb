# encoding: utf-8

module DataMapper
  module Validation
    class Rule
      module Formats

        # Regex from http://www.igvita.com/2006/09/07/validating-url-in-ruby-on-rails/
        Url = begin
          /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}((\:[0-9]{1,5})?\/?.*)?$)/ix
        end

      end # module Formats
    end # class Rule
  end # module Validation
end # module DataMapper

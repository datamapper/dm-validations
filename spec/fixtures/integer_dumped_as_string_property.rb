# Property to test dumped_as != loaded_as behaviour
module DataMapper
  class Property
    class IntegerDumpedAsStringProperty < DataMapper::Property::Object
      load_as ::Integer
      dump_as ::String

      accept_options :length

      DEFAULT_LENGTH = 50
      length(DEFAULT_LENGTH)

      attr_reader :length

      def dump(value)
        value.nil? ? nil : value.to_s
      end

      def load(value)
        value.nil? ? nil : value.to_i
      end
    end
  end
end

# Property to test dumped_as != loaded_as behaviour
module DataMapper
  class Property
    class IntegerDumpedAsStringProperty < DataMapper::Property::Object
      dump_as ::String
      load_as ::Integer

      def dump(value)
        value.nil? ? nil : value.to_s
      end

      def load(value)
        value.nil? ? nil : value.to_i
      end
    end
  end
end


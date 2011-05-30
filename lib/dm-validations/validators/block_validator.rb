module DataMapper
  module Validations
    # @author teamon
    # @since  0.9
    module ValidatesWithBlock
      # Validate using the given block. The block given needs to return:
      # [result::<Boolean>, Error Message::<String>]
      #
      # @example [Usage]
      #   require 'dm-validations'
      #
      #   class Page
      #     include DataMapper::Resource
      #
      #     property :zip_code, String
      #
      #     validates_with_block do
      #       if @zip_code == "94301"
      #         true
      #       else
      #         [false, "You're in the wrong zip code"]
      #       end
      #     end
      #
      #     # A call to valid? will return false and
      #     # populate the object's errors with "You're in the
      #     # wrong zip code" unless zip_code == "94301"
      #
      #     # You can also specify field:
      #
      #     validates_with_block :zip_code do
      #       if @zip_code == "94301"
      #         true
      #       else
      #         [false, "You're in the wrong zip code"]
      #       end
      #     end
      #
      #     # it will add returned error message to :zip_code field
      #
      def validates_with_block(*fields, &block)
        @__validates_with_block_count ||= 0
        @__validates_with_block_count += 1

        # create method and pass it to MethodValidator
        unless block_given?
          raise ArgumentError, 'You need to pass a block to validates_with_block method'
        end

        method_name = "__validates_with_block_#{@__validates_with_block_count}".to_sym
        define_method(method_name, &block)

        options = fields.last.is_a?(Hash) ? fields.last.pop.dup : {}
        options[:method] = method_name
        fields = [method_name] if fields.empty?

        validators.add(MethodValidator, *fields + [options])
      end
    end # module ValidatesWithMethod
  end # module Validations
end # module DataMapper

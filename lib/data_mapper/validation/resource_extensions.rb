require 'data_mapper/core'
require 'data_mapper/validation'
require 'data_mapper/validation/context'

module DataMapper
  module Validation

    module ResourceExtensions

      def self.included(model)
        model.before :save, :validate_or_halt
      end

      # Ensures the object is valid for the context provided, and otherwise
      # throws :halt and returns false.
      #
      # @param [Symbol] context
      #   context for which to validate the Resource, defaulting to
      #   #default_validation_context
      # 
      # @return [Boolean]
      #   whether the Resource was persisted successfully
      # 
      # TODO: fix this to not change the method signature of #save
      # TODO: add support for skipping validations by passing nil
      #
      # @api public
      def save(context_name = default_validation_context)
        validation_rules.assert_valid_context(context_name)

        Context.in_context(context_name) { super() }
      end

      # Ensures the object is valid for the context provided, and otherwise
      # throws :halt and returns false.
      #
      # @param [Hash] attributes
      #   attribute names and values which will be set on this Resource
      # @param [Symbol] context
      #   context for which to validate the Resource, defaulting to
      #   #default_validation_context
      #
      # @return [Boolean]
      #   whether the Resource attributes were set and persisted successfully
      # 
      # TODO: fix this to not change the method signature of #update
      #
      # @api public
      def update(attributes = {}, context_name = default_validation_context)
        validation_rules.assert_valid_context(context_name)

        Context.in_context(context_name) { super(attributes) }
      end

      # @api public
      def validate(context_name = default_validation_context)
        super
        validate_parents  # if model.validation_rules.validate_parents?
        validate_children # if model.validation_rules.validate_children?

        self
      end

    private

      # @api private
      def validate_parents
        parent_relationships.each do |relationship|
          next unless relationship.loaded?(self)
          validate_parent_relationship(relationship)
        end
      end

      # @api private
      def validate_children
        child_relationships.each do |relationship|
          next unless relationship.loaded?(self)
          validate_child_relationship(relationship)
        end
      end

      # @api private
      def validate_parent_relationship(relationship)
        relationship_name = relationship.name
        parent_model      = relationship.target_model
        context_name      = parent_model.validation_rules.current_context
        parent_resource   = relationship.get(self)

        parent_violations = parent_resource.validation_violations(context_name)
        parent_violations.each { |v| errors[relationship_name] << v }
      end

      # @api private
      def validate_child_relationship(relationship)
        relationship_name = relationship.name
        child_model       = relationship.target_model
        context_name      = child_model.validation_rules.current_context
        child_collection  = relationship.get_collection(self)

        child_collection.each do |child_resource|
          child_violations = child_resource.validation_violations(context_name)
          child_violations.each { |v| errors[relationship_name] << v }
        end
      end

      # @api private
      def validate_or_halt
        throw :halt if Context.any? && !valid?(validation_rules.current_context)
      end

    end # module Resource
  end # module Validation

  Model.append_inclusions Validation
  Model.append_inclusions Validation::ResourceExtensions

end

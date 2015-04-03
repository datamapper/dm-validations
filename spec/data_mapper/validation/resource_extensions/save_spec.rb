require 'spec_helper'
require 'data_mapper/validation/resource_extensions'

describe DataMapper::Validation::ResourceExtensions, '#save' do
  before :all do
    class SaveTestResource
      include DataMapper::Resource

      property :id, Serial

      def _persist
        self
      end
    end

    SaveTestResource.finalize
  end

  subject { SaveTestResource.new }

  it 'returns false when #valid? returns false' do
    subject.should_receive(:valid?).and_return(false)

    subject.save.should be_false
  end

  it 'calls #validation_rules.assert_valid_context with its #default_validation_context' do
    context_name = :default
    contextual_rule_set = mock(DataMapper::Validation::ContextualRuleSet)
    contextual_rule_set.stub(:current_context)
    subject.stub(:save_self)
    subject.stub(:validation_rules => contextual_rule_set)

    subject.should_receive(:default_validation_context).and_return(context_name)
    contextual_rule_set.should_receive(:assert_valid_context).with(context_name)

    subject.save
  end

  it 'calls #save_self' do
    subject.should_receive(:save_self)

    subject.save
  end

  it 'pushes its default_validation_context on the Context stack' do
    context_name = :default
    subject.stub(:default_validation_context => context_name)
    subject.should_receive(:_save) do
      DataMapper::Validation::Context.current.should be(context_name)
    end

    subject.save
  end

end

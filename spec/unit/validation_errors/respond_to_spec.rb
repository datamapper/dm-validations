require 'spec_helper'

describe 'DataMapper::Validations::ValidationErrors#respond_to?' do

  subject { DataMapper::Validations::ValidationErrors.new(Object.new) }

  it 'should look for the method in self' do
    subject.should respond_to(:full_messages)
  end

  it 'should delegate lookup to the underlying errors hash' do
    subject.should respond_to(:size)
  end

end

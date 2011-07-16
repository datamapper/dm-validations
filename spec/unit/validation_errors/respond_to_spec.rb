require 'spec_helper'

describe 'DataMapper::Validations::ErrorSet#respond_to?' do

  subject { DataMapper::Validations::ErrorSet.new(Object.new) }

  it 'should look for the method in self' do
    subject.should respond_to(:full_messages)
  end

  it 'should delegate lookup to the underlying errors hash' do
    subject.should respond_to(:size)
  end

end

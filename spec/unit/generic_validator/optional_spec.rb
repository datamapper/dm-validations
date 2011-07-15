require 'spec_helper'

describe 'DataMapper::Validations::Rule::Generic', '#optional?' do
  def validator(opts = {})
    DataMapper::Validations::Rule::Length.new(:name, opts)
  end

  describe 'allowing blank' do
    subject do
      validator(
        :allow_blank => true
      )
    end

    it { subject.optional?("" ).should be }
    it { subject.optional?(nil).should be }
  end

  describe 'allowing nil' do
    subject do
      validator(
        :allow_nil => true
      )
    end

    it { subject.optional?("" ).should_not be }
    it { subject.optional?(nil).should be }
  end

  describe 'allowing blank, but now allowing nil' do
    subject do
      validator(
        :allow_blank => true,
        :allow_nil   => false
      )
    end

    it { subject.optional?("" ).should be }
    it { subject.optional?(nil).should_not be }
  end

  describe 'allowing nil, but now allowing blank' do
    subject do
      validator(
        :allow_blank => false,
        :allow_nil   => true
      )
    end

    it { subject.optional?("" ).should_not be }
    it { subject.optional?(nil).should be }
  end

end

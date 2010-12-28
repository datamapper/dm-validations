# put validator specific fixture models and helpers here
#
# make sure you check out spec/fixtures to see fixture models
# already written
#
# DataMapper developers feels strongly against foobars in the spec
# suite

# TODO: one day we need to get rid of this remaining foobarness
# and use a few more realistic models with ParanoidBoolean and all
# that

class SailBoat
  include DataMapper::Resource

  # this one is not Serial intentionally
  # use Serial in real world apps
  property :id,            Integer,    :key => true, :min => 1, :max => 10

  property :name,          String,                                :required => true,     :validates       => :presence_test
  property :description,   String,     :length => 10,                                     :validates       => :length_test_1
  property :notes,         String,     :length => 2..10,                                  :validates       => :length_test_2
  property :no_validation, String,                                                        :auto_validation => false
  property :salesman,      String,                                :required => true,     :validates       => [:multi_context_1, :multi_context_2]
  property :code,          String,     :format => Proc.new { |code| code =~ /A\d{4}\z/ }, :validates       => :format_test
  property :allow_nil,     String,     :length => 5..10,          :required => false,      :validates       => :nil_test
  property :build_date,    Date,                                                          :validates       => :primitive_test
  property :float,         Float,      :precision => 2, :scale => 1
  property :big_decimal,   Decimal, :precision => 2, :scale => 1
end

class HasNullableBoolean
  include DataMapper::Resource

  # this one is not Serial intentionally
  # use Serial in real world apps
  property :id,   Integer, :key => true
  property :bool, Boolean # :required => false by default
end

class HasRequiredBoolean
  include DataMapper::Resource

  # this one is not Serial intentionally
  # use Serial in real world apps
  property :id,   Integer, :key => true
  property :bool, Boolean, :required => true
end

class HasRequiredParanoidBoolean
  include DataMapper::Resource

  # this one is not Serial intentionally
  # use Serial in real world apps
  property :id,   Integer,         :key => true
  property :bool, ParanoidBoolean, :required => true
end

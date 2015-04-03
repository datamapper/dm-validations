# encoding: utf-8

module DataMapper
  module Validation
    class Rule
      module Formats

        Url = %r{\Ahttps?://[a-z\d](?:[-.]?[a-z\d])*\.[a-z]{2,6}(?::\d{1,5})?/?.*\z}ix.freeze

      end # module Formats
    end # class Rule
  end # module Validation
end # module DataMapper

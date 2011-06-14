class Object
  # If receiver is callable, calls it and returns result.
  # If not, just returns receiver itself
  #
  # @return [Object]
  # @api private
  def try_call(*args)
    if self.respond_to?(:call)
      self.call(*args)
    else
      self
    end
  end

  def validatable?
    false
  end
end

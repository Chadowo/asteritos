# Compatibility module for use between CRuby and MRuby
module MRubyCompatibility
  # MRuby PRNG function doesn't support Ranges as arguments, so
  # we'll have to make our own function for that
  def rand(max = 0)
    if max.is_a? Range
      Kernel.rand(max.max - max.min) + max.min
    else
      Kernel.rand(max)
    end
  end

  module_function :rand
end

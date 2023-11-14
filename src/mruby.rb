# Compatibilty module for use between CRuby and MRuby
module MRuby
  # MRuby random number generator doesn't support Ranges as arguments
  # that are used extensively in this game, so we'll do an abstraction
  # ourselves
  def rand(max = 0)
    if max.is_a? Range
      Kernel.rand(max.max - max.min) + max.min
    else
      Kernel.rand(max)
    end
  end

  module_function :rand
end

# File that will handle compatibility between CRuby and MRuby

module Kernel
  # Based on: https://github.com/steveklabnik/require_relative
  # without REGEX since it's not bundled yet in the gosu-mruby-wrapper
  def require_relative(path)
    file = caller.first.split(':', 2).first

    require(File.expand_path(path, File.dirname(file)))
  end
end

# Available when running on MRuby
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

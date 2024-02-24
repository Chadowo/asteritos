# Simple monkeypatch to make MRuby's rand support Ranges
module RandomExt
  def rand(max = 0)
    if max.is_a? Range
      Kernel.rand(max.max - max.min) + max.min
    else
      Kernel.rand(max)
    end
  end

  module_function :rand
end

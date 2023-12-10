class BlinkingText
  attr_accessor :label, :interval, :blink, :scale_x, :scale_y, :timer

  def initialize(font, label, interval)
    @font = font
    @label = label

    @interval = interval
    @blink = false

    @w = @font.text_width(@label)
    @h = @font.height

    @scale_x = 1.0
    @scale_y = 1.0

    @timer = 0.0
  end

  # Return the width based on scale
  def w
    @w = @font.text_width(@label) * @scale_x
  end

  # Return the height based on scale
  def h
    @h = @font.height * @scale_y
  end

  def update(dt)
    @timer += dt

    if @timer >= @interval
      @blink = !@blink
      @timer = 0.0
    end
  end

  def draw(x, y, z, color: Gosu::Color::WHITE)
    current_color = @blink ? Gosu::Color.new(0, 0, 0, 0) : color

    @font.draw_text(@label, x, y, z, @scale_x, @scale_y, current_color)
  end
end

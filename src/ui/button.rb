
class Button
  attr_accessor :x, :y, :scale_x, :scale_y
  attr_reader :label, :w, :h

  def initialize(font, label, action, inactive_color: Gosu::Color::GRAY, active_color: Gosu::Color::WHITE)
    @font = font

    @label = label
    @action = action

    @active = false

    @inactive_color = inactive_color
    @active_color = active_color

    @current_color = @inactive_color

    @x = 0
    @y = 0

    @w = @font.text_width(@label)
    @h = @font.height

    @scale_x = 1.0
    @scale_y = 1.0
  end

  # Determine if the mouse is selecting this button
  def check_mouse(window)
    highlight(window.mouse_x, window.mouse_y)
    click
  end

  # FIXME: Collision checking doesn't appear to be exact on the y axis, it detects
  #        a collision even though the button is a few pixels away from the mouse.
  #        The problem isn't new to the button addition, it's present in the jam
  #        version too
  def highlight(mouse_x, mouse_y)
    if mouse_x > @x && mouse_x < @x + (@w * @scale_x) &&
       mouse_y > @y && mouse_y < @y + (@h * @scale_y)
    then
      @active = true
      @current_color = @active_color
    else
      @active = false
      @current_color = @inactive_color
    end
  end

  def click
    @action.call if @active && Gosu.button_down?(Gosu::MS_LEFT)
  end

  def draw
    @font.draw_text(@label, @x, @y, 0, @scale_x, @scale_y, @current_color)
  end
end
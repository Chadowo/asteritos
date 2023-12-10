class Button
  attr_accessor :x, :y, :scale_x, :scale_y
  attr_reader :label, :w, :h

  # FIXME: This is way to big
  def initialize(font, label, action,
                 inactive_color: Gosu::Color::GRAY, active_color: Gosu::Color::WHITE,
                 select_sfx: nil, press_sfx: nil)
    @font = font

    @label = label
    @action = action

    @active = false

    @inactive_color = inactive_color
    @active_color = active_color
    @current_color = @inactive_color

    @select_sfx = select_sfx
    @press_sfx = press_sfx

    @x = 0
    @y = 0

    @w = @font.text_width(@label)
    @h = @font.height

    @scale_x = 1.0
    @scale_y = 1.0
  end

  # Determine if the mouse is selecting this button
  def check_mouse(window)
    highlight(window)
    click
  end

  # NOTE: Collision checking doesn't appear to be exact on the y axis, it detects
  #       a collision even though the button is a few pixels away from the mouse.
  #       The problem isn't new to the button addition, It seems upon further
  #       investigation that this may be related to the font, in which case there's
  #       not a lot I can do
  def highlight(window)
    mouse_x = window.mouse_x
    mouse_y = window.mouse_y

    # FIXME: Halfways there, but I should for other solution most likely, this is plainly not elegant
    if mouse_x >= x && mouse_x <= x + (@w * @scale_x) &&
       mouse_y >= y && mouse_y <= y + (@h * @scale_y)
    then
      @select_sfx&.play unless @active # Unless active so it plays only one time

      @active = true
      @current_color = @active_color
    else
      @active = false
      @current_color = @inactive_color
    end
  end

  def click
    return unless @active && Gosu.button_down?(Gosu::MS_LEFT)

    @press_sfx&.play
    @action.call
  end

  def draw
    @font.draw_text(@label, @x, @y, 0, @scale_x, @scale_y, @current_color)
  end
end

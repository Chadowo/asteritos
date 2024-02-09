class Button
  attr_accessor :x, :y, :scale_x, :scale_y, :active
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

  def select!
    @select_sfx&.play unless @active # Unless active so it plays only one time

    @active = true
    @current_color = @active_color
  end

  def deselect!
    @active = false
    @current_color = @inactive_color
  end

  def use!
    return unless @active

    @press_sfx&.play
    @action.call
  end

  def draw
    @font.draw_text(@label, @x, @y, 0, @scale_x, @scale_y, @current_color)
  end
end

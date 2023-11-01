
class MenuState < State
  def enter(args); end

  def initialize(window)
    @window = window

    @bg = Gosu::Image.new('assets/sprites/bg.png')
    @font = Gosu::Font.new(60, name: 'assets/fonts/nordine/nordine.ttf')

    options = {
      lives: 3,
      difficulty: :normal
    }

    # TODO: Can't discern too much here
    @buttons = [
      Button.new(@font, 'Play', -> { @window.change_state(GameState.new(@window), options) },
                 inactive_color: Gosu::Color::WHITE, active_color: Gosu::Color::RED),
      Button.new(@font, 'Settings', -> { puts 'Going to settings...'},
                 inactive_color: Gosu::Color.new(150, 255, 255, 255), active_color: Gosu::Color::RED),
      Button.new(@font, 'Quit', -> { @window.close },
                 inactive_color: Gosu::Color::WHITE, active_color: Gosu::Color::RED)
    ]
  end

  def update(dt)
    @buttons.each do |btn|
      btn.check_mouse(@window) unless btn.label == 'Settings' # Not implemented yet
    end
  end

  def draw
    @bg.draw(0, 0, 0)

    draw_title
    draw_buttons
  end

  def draw_title
    width = @font.text_width('Asteritos')
    height = @font.height

    # Draw centered on screen
    @font.draw_text('Asteritos',
                    (@window.width / 2) - (width / 2),
                    (@window.height / 2) - (height / 2),
                    0)
  end

  def draw_buttons
    ww = @window.width
    wh = @window.height

    cursor_y = 0

    scale = 0.4
    margin = 16

    total_height = ((60 * scale) + margin) * 3

    @buttons.each do |btn|
      width = btn.w * scale
      height = btn.h * scale

      btn.scale_x = scale
      btn.scale_y = scale

      # Button coordinates
      # NOTE: The extra 100 on the y is to account for the title position
      btn.x = (ww / 2) - (width / 2)
      btn.y = (wh / 2 + 100) - total_height / 2 + cursor_y

      btn.draw

      cursor_y += height + margin
    end
  end
end

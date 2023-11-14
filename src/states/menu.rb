
require 'ui/button'

class MenuState < State
  def enter(args); end

  def initialize(window)
    @window = window

    @font = Gosu::Font.new(60, name: 'assets/fonts/nordine/nordine.ttf')
    @bg = Gosu::Image.new('assets/sprites/bg.png')

    options = {
      lives: 3,
      difficulty: :normal
    }

    initialize_audio

    # FIXME: Adding sound really doesn't make this better to the eye...
    @buttons = [
      Button.new(@font, 'Play', -> { @window.change_state(GameState.new(@window), options) },
                 inactive_color: Gosu::Color::WHITE, active_color: Gosu::Color::RED,
                 select_sfx: @select_sfx, press_sfx: @press_sfx),

      Button.new(@font, 'Settings', -> { puts 'Going to settings...'},
                 inactive_color: Gosu::Color.new(150, 255, 255, 255), active_color: Gosu::Color::RED,
                 select_sfx: @select_sfx, press_sfx: @press_sfx),

      Button.new(@font, 'Quit', -> { @window.close },
                 inactive_color: Gosu::Color::WHITE, active_color: Gosu::Color::RED,
                 select_sfx: @select_sfx, press_sfx: @press_sfx)
    ]
  end

  def initialize_audio
    @select_sfx = Gosu::Sample.new('assets/sfx/menu/select.wav')
    @press_sfx = Gosu::Sample.new('assets/sfx/menu/press.wav')
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
                    (AsteritosWindow::WINDOW_WIDTH / 2) - (width / 2),
                    (AsteritosWindow::WINDOW_HEIGHT / 2) - (height / 2),
                    0)
    @font.draw_text("v#{AsteritosWindow::VERSION}",
                    510, 320, 0,
                    0.4, 0.4,
                    Gosu::Color::RED)
  end

  def draw_buttons
    ww = AsteritosWindow::WINDOW_WIDTH
    wh = AsteritosWindow::WINDOW_HEIGHT

    cursor_y = 0

    scale = 0.4
    margin = 16

    total_height = ((@font.height * scale) + margin) * 3

    @buttons.each do |btn|
      width = btn.w * scale
      height = btn.h * scale

      btn.scale_x = scale
      btn.scale_y = scale

      # Button coordinates
      # NOTE: The extra 100 on the y is to account for the title position
      btn.x = (ww / 2) - (width / 2)
      btn.y = (wh / 2 + 100) - total_height / 2 + cursor_y

      @font.draw_text('<- Not implemented yet!',
                      btn.x + 130,
                      btn.y + 2,
                      0,
                      0.3,
                      0.3) if btn.label == 'Settings'

      btn.draw

      cursor_y += height + margin
    end
  end
end

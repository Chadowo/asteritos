require 'controls'
require 'state'

require 'ui/button'

class MenuState < State
  def enter(args); end

  def initialize(window)
    initialize_audio

    @window = window

    @font = Gosu::Font.new(60, name: 'assets/fonts/nordine/nordine.ttf')
    @bg = Gosu::Image.new('assets/sprites/bg.png')

    options = {
      lives: 3,
      difficulty: :normal
    }

    # FIXME: Adding sound really doesn't make this better to the eye...
    @buttons = [
      Button.new(@font, 'Play', -> { @window.change_state(GameState.new(@window), options) },
                 inactive_color: Gosu::Color::WHITE, active_color: Gosu::Color::RED,
                 select_sfx: @select_sfx, press_sfx: @press_sfx),

      Button.new(@font, 'Settings', -> { puts 'Going to settings...' },
                 inactive_color: Gosu::Color.new(150, 255, 255, 255), active_color: Gosu::Color::RED,
                 select_sfx: @select_sfx, press_sfx: @press_sfx),

      Button.new(@font, 'Quit', -> { @window.close },
                 inactive_color: Gosu::Color::WHITE, active_color: Gosu::Color::RED,
                 select_sfx: @select_sfx, press_sfx: @press_sfx)
    ]
    @button_cursor = nil
  end

  def initialize_audio
    @select_sfx = Gosu::Sample.new('assets/sfx/menu/select.ogg')
    @press_sfx = Gosu::Sample.new('assets/sfx/menu/press.ogg')
  end

  def update(_dt)
    buttons_handle_mouse
  end

  def button_down(key)
    buttons_handle_keyboard(key)
  end

  def buttons_handle_mouse
    @buttons.each do |btn|
      mouse_x = @window.mouse_x
      mouse_y = @window.mouse_y

      if mouse_x >= btn.x && mouse_x <= btn.x + (btn.w * btn.scale_x) &&
         mouse_y >= btn.y && mouse_y <= btn.y + (btn.h * btn.scale_y)
      then
        btn.select! unless btn.label == 'Settings' # Not implemented yet
        btn.use! if Gosu.button_down?(Gosu::MS_LEFT)
      else
        btn.deselect! unless !@button_cursor.nil? && btn == @buttons[@button_cursor]
      end
    end
  end

  def buttons_handle_keyboard(key)
    if Controls::DOWN.include?(key)
      # If it is nil then nothing was selected before, select the first
      # button then
      if @button_cursor.nil?
        @button_cursor = 0
        @buttons[@button_cursor].select!
        return
      end

      # Make sure we're not out of the bounds of the buttons array
      return if @button_cursor == @buttons.length - 1

      # Deselect the previous button
      @buttons[@button_cursor].deselect!
      # We'll skip the settings one since it's not finished up yet
      @button_cursor += if @buttons[@button_cursor + 1].label == 'Settings'
                          2
                        else
                          1
                        end
    elsif Controls::UP.include?(key)
      # If it is nil then nothing was selected before, select the first
      # button then
      if @button_cursor.nil?
        @button_cursor = @buttons.length - 1
        @buttons[@button_cursor].select!
        return
      end

      # Make sure we're not out of the bounds of the buttons array
      return if @button_cursor.zero?

      # Deselect the previous button
      @buttons[@button_cursor].deselect!
      # We'll skip the settings one since it's not finished up yet
      @button_cursor -= if @buttons[@button_cursor - 1].label == 'Settings'
                          2
                        else
                          1
                        end
    end

    unless @button_cursor.nil?
      @buttons[@button_cursor].select!
      @buttons[@button_cursor].use! if Controls::ENTER.include?(key)
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

      if btn.label == 'Settings'
        @font.draw_text('<- Not implemented yet!',
                        btn.x + 130, btn.y + 2, 0,
                        0.3, 0.3)
      end

      btn.draw

      cursor_y += height + margin
    end
  end
end

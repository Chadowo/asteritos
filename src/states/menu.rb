
class MenuState < State
  def enter(args); end

  def initialize(window)
    @window = window

    @bg = Gosu::Image.new('assets/sprites/bg.png')

    @main_font = Gosu::Font.new(60, name: 'assets/fonts/nordine/nordine.ttf')
    @width = @main_font.text_width('Asteritos')

    options = {
      lives: 3,
      difficulty: :normal
    }

    @buttons = {
      play: { label: 'Play', callback: -> { @window.change_state(GameState.new(@window), options) } },
      settings: { label: 'Settings', callback: -> { puts 'Going to settings...' } },
      quit: { label: 'Quit', callback: -> { exit(0) } }
    }
  end

  def update(dt)
  end

  def draw
    @bg.draw(0, 0, 0)
    @main_font.draw_text('Asteritos',
                         (@window.width / 2) - (@width / 2),
                         (@window.height / 2) - (60 / 2),
                         0)

    draw_buttons
  end

  def draw_buttons
    ww = @window.width
    wh = @window.height

    margin = 16
    scale = 0.4
    total_height = ((60 * scale) + margin) * 3

    cursor_y = 0

    @buttons.each do |key, value|
      width = @main_font.text_width(value[:label]) * scale

      # Button coordinates
      bx = (ww / 2) - (width / 2)
      by = (wh / 2 + 100) - total_height / 2 + cursor_y

      color = Gosu::Color::WHITE

      # Highlight if selected
      # TODO: Separate this logic from here
      if @window.mouse_x > bx && @window.mouse_x < bx + width &&
         @window.mouse_y > by && @window.mouse_y < by + 60 * scale
        color = Gosu::Color::RED

        # TODO: This shouldn't be here really
        value[:callback].call if Gosu.button_down?(Gosu::MS_LEFT)
      end

      # As of this version an options menu isn't implemented, better to note
      # this to the player by lowering the opacity of the button and adding a
      # label
      color = Gosu::Color.new(150, 255, 255, 255) if key == :settings
      @main_font.draw_text("<- Not implemented yet!",
                           bx + 130,
                           by + 2,
                           0,
                           0.3,
                           0.3) if key == :settings

      @main_font.draw_text(value[:label],
                           bx,
                           by,
                           0,
                           scale,
                           scale,
                           color)

      cursor_y += 60 * scale + margin
    end
  end
end


require 'gosu' unless RUBY_ENGINE == 'mruby'

require File.expand_path('mruby', File.dirname(__FILE__))

# Require everything needed
require './src/state'
require './src/states/menu'
require './src/states/game'

require './src/entities/ship'
require './src/entities/bullet'
require './src/entities/asteroid'

require './src/ui/button'
require './src/ui/blink_text'

require './src/version'

class AsteritosWindow < Gosu::Window
  WINDOW_WIDTH = 800
  WINDOW_HEIGHT = 600

  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT, resizable: true)
    self.caption = 'Asteritos'

    # Timing
    @dt = 0.0
    @last_ms = 0.0

    @current_state = MenuState.new(self)

    @scale_w = 1.0
    @scale_h = 1.0
    @off_x = 0.0
    @off_y = 0.0
  end

  def needs_cursor?
    true
  end

  def change_state(state, args)
    state.enter(args)
    @current_state = state
  end

  def update
    @current_state.update(@dt)

    update_delta
    update_dimensions

    self.close if Gosu.button_down?(Gosu::KB_ESCAPE)
  end

  def button_down(key)
    @current_state.button_down(key)
  end

  def update_delta
    current_time = Gosu.milliseconds / 1000.0
    @dt = [current_time - @last_ms, 0.25].min
    @last_ms = current_time
  end

  def update_dimensions
    scale_w = self.width / WINDOW_WIDTH.to_f
    scale_h = self.height / WINDOW_HEIGHT.to_f
    scale = [scale_w, scale_h].min

    @off_x = (scale_w - scale) * (WINDOW_WIDTH / 2)
    @off_y = (scale_h - scale) * (WINDOW_HEIGHT / 2)
    @scale_w = scale
    @scale_h = scale
  end

  def draw
    Gosu.translate(@off_x, @off_y) do
      Gosu.scale(@scale_w, @scale_h, 0.5, 0.5) do
        @current_state.draw
      end
    end
  end
end

AsteritosWindow.new.show

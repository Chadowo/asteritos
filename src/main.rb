
require 'gosu' unless RUBY_ENGINE == 'mruby'

require File.expand_path('mruby', File.dirname(__FILE__))

require_relative 'state'
require_relative 'states/menu'
require_relative 'states/game'

require_relative 'ui/button'

require_relative 'version'

class AsteritosWindow < Gosu::Window
  WINDOW_WIDTH = 800
  WINDOW_HEIGHT = 600

  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT)
    self.caption = 'Asteritos'

    # Timing
    @dt = 0.0
    @last_ms = 0.0

    @current_state = MenuState.new(self)
  end

  def needs_cursor?
    true
  end

  def change_state(state, args)
    state.enter(args)
    @current_state = state
  end

  def update
    update_delta

    @current_state.update(@dt)

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

  def draw
    @current_state.draw
  end
end

AsteritosWindow.new.show


unless RUBY_ENGINE == 'mruby'
  require 'gosu' 
  require 'logger' 

  $: << 'src' # Assuming this file is executed instead of the entrypoint
end

require File.expand_path('mruby', File.dirname(__FILE__))

# Require everything needed
require 'state'
require 'states/menu'
require 'states/game'

require 'version'

class AsteritosWindow < Gosu::Window
  attr_accessor :logger
  attr_reader :off_x, :off_y, :scale_x, :scale_y

  WINDOW_WIDTH = 800
  WINDOW_HEIGHT = 600

  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT, resizable: true)
    self.caption = 'Asteritos'

    # Timing
    @dt = 0.0
    @last_ms = 0.0

    @current_state = MenuState.new(self)

    @logger = Logger.new(STDOUT)
    @logger.progname = 'Asteritos'
    @logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{datetime}] #{severity.ljust(5)} -- #{progname}: #{msg}\n"
    end

    @logger.info('Logger initialized')
    @logger.info("Asteritos version: v#{AsteritosWindow::VERSION}")
    @logger.info("Gosu version: v#{Gosu::VERSION}")
    @logger.info("Ruby version: #{RUBY_ENGINE == 'ruby' ? RUBY_DESCRIPTION : MRUBY_DESCRIPTION}")
    @logger.info('Have a good day ;)!')

    @scale_x = 1.0
    @scale_y = 1.0
    @off_x = 0.0
    @off_y = 0.0
  end

  def needs_cursor?
    true
  end

  def change_state(state, args)
    @logger.info("Entered state #{state.class}")

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
    scale_x = self.width / WINDOW_WIDTH.to_f
    scale_y = self.height / WINDOW_HEIGHT.to_f
    scale = [scale_x, scale_y].min

    @off_x = (scale_x - scale) * (WINDOW_WIDTH / 2)
    @off_y = (scale_y - scale) * (WINDOW_HEIGHT / 2)
    @scale_x = scale
    @scale_y = scale
  end

  def draw
    Gosu.translate(@off_x, @off_y) do
      Gosu.scale(@scale_x, @scale_y, 0.5, 0.5) do
        @current_state.draw
      end
    end
  end
end

game = AsteritosWindow.new
begin
  game.show
rescue Exception => e
  game.logger.fatal("An exception has ocurred: #{e}")
  game.logger.fatal("Backtrace: #{e.backtrace.join("\n\t")}")
  raise e
end

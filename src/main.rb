unless RUBY_ENGINE == 'mruby'
  require 'gosu'
  require 'logger'

  # Assuming this file is executed instead of the entrypoint
  $: << 'src'
  $: << 'src/libs/aniruby'
end

require 'mruby'

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
    super(WINDOW_WIDTH, WINDOW_HEIGHT)
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

game = AsteritosWindow.new
begin
  game.show
rescue Exception => e
  game.logger.fatal("An exception has ocurred: #{e}")
  game.logger.fatal("Backtrace: #{e.backtrace.join("\n\t")}")
  raise e
end

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

    # TODO: Twenning
    @next_state = nil
    @next_state_args = nil
    @transition_color = Gosu::Color.rgba(0, 0, 0, 0)
    @transitioning = false
  end

  def needs_cursor?
    true
  end

  def transition_done?
    true if @transition_color.alpha == 255
  end

  def change_state(state, args)
    return if @transitioning

    @next_state = state
    @next_state_args = args

    @transitioning = true
    @logger.info("Changing to #{state.class} state")
  end

  def update
    update_delta

    # Increase or decrease the transition alpha depending on whether we're on
    # a transition or not
    # NOTE: The alpha is clamped automatically between 0 and 255
    @transition_color.alpha += 650 * @dt if @transitioning
    @transition_color.alpha -= 650 * @dt unless @transitioning
    if transition_done?
      @next_state.enter(@next_state_args)
      @current_state = @next_state

      @transitioning = false
    end

    return if @transitioning

    @current_state.update(@dt)

    self.close if Gosu.button_down?(Gosu::KB_ESCAPE)
  end

  def button_down(key)
    return if @transitioning # Stop player from pressing something while transitioning

    @current_state.button_down(key)
  end

  def update_delta
    current_time = Gosu.milliseconds / 1000.0
    @dt = [current_time - @last_ms, 0.25].min
    @last_ms = current_time
  end

  def draw
    @current_state.draw
    Gosu.draw_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, @transition_color)
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

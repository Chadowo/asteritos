$: << 'src'
$: << 'src/libs/aniruby'

unless RUBY_ENGINE == 'mruby'
  require 'gosu'
  require 'logger'
end

require 'states/menu'
require 'states/game'
require 'version'

# The principal window of the game, also works as a
# state manager/controller too via a stack of states
class AsteritosWindow < Gosu::Window
  attr_accessor :logger

  WINDOW_WIDTH = 800
  WINDOW_HEIGHT = 600
  TRANSITION_SPEED = 750

  def initialize
    super(WINDOW_WIDTH, WINDOW_HEIGHT)
    self.caption = 'Asteritos'

    # Timing stuff
    @dt = 0.0
    @last_ms = 0.0

    # We'll handle states like a stack
    @states = []
    @states.push(MenuState.new(self))
    # This will hold the state we'll need to change to after a transition
    @requested_state = nil

    # TODO: Make this its own screen effect class
    @transition_color = Gosu::Color.rgba(0, 0, 0, 0)
    @transitioning = false

    # Logging related things, pretty trivial
    @logger = Logger.new($stdout)
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

  def transition_done?
    true if @transition_color.alpha == 255
  end

  # Change the current state to the requested one BUT not immediately
  # since a simple fade in/out transitions has to play
  def change_state(state, _args)
    return if @transitioning

    @requested_state = state
    @transitioning = true

    @logger.info("Changing to #{state.class} state")
  end

  def update
    update_delta
    update_transition(@dt)

    return if @transitioning

    @states.last.update(@dt)
    self.close if Gosu.button_down?(Gosu::KB_ESCAPE)
  end

  def update_delta
    current_time = Gosu.milliseconds / 1000.0
    @dt = [current_time - @last_ms, 0.25].min
    @last_ms = current_time
  end

  def update_transition(dt)
    # Increase alpha when transitioning, and decrease when the state has changed
    # already
    # NOTE: The alpha is clamped automatically between 0 and 255
    @transition_color.alpha += TRANSITION_SPEED * dt if @transitioning
    @transition_color.alpha -= TRANSITION_SPEED * dt unless @transitioning

    return unless transition_done?

    # Once the transition is done, we'll change to the requested state
    # and start the fade out
    @states.pop if @states.any?
    @states.push(@requested_state)
    @transitioning = false
  end

  def button_down(key)
    return if @transitioning

    @states.last.button_down(key)
  end

  def draw
    @states.last.draw
    Gosu.draw_rect(0, 0, WINDOW_WIDTH, WINDOW_HEIGHT, @transition_color)
  end
end

game = AsteritosWindow.new
begin
  game.show
rescue Exception => e # rubocop:disable Lint/RescueException
  game.logger.fatal("An exception has ocurred: #{e}")
  game.logger.fatal("Backtrace: #{e.backtrace.join("\n\t")}")
  raise e
end

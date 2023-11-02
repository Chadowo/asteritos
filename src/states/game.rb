
require_relative '../entities/ship'
require_relative '../entities/asteroid'

require_relative '../ui/blink_text'

# FIXME: There's way too much logic in here
class GameState < State
  MINIMUM_SHIP_DISTANCE = 250
  ASTEROIDS_AMOUNT = 6

  # TODO: Change the game based on the options
  def enter(options)
    unless options.nil?
      @options = options
    end
  end

  # TODO: Organize this
  def initialize(window)
    default_options = { lives: 3,
                        difficulty: :normal }

    @options = default_options

    @window = window

    @font = Gosu::Font.new(22, name: 'assets/fonts/nordine/nordine.ttf')
    @bg = Gosu::Image.new('assets/sprites/bg.png')

    @score = 0
    @highscore = if File.exist?('data/score.txt')
                   File.read('data/score.txt').to_i
                 else
                   0
                 end

    @lives = @options[:lives]
    @pause = false
    @gameover = false

    @pause_text = BlinkingText.new(@font, 'PAUSED', 0.4)
    @pause_text.scale_x = 1.4
    @pause_text.scale_y = 1.4

    initialize_entities
    initialize_audio

    generate_asteroids(ASTEROIDS_AMOUNT)
  end

  def initialize_entities
    @player = Ship.new(AsteritosWindow::WINDOW_WIDTH / 2,
                       AsteritosWindow::WINDOW_HEIGHT / 2)
    @asteroids = []
  end

  def initialize_audio
    @player_destroyed_sfx = Gosu::Sample.new('assets/sfx/game/player_destroyed.wav')
    @asteroid_destroyed_sfx = Gosu::Sample.new('assets/sfx/game/asteroid_destroyed.wav')
    @pause_sfx = Gosu::Sample.new('assets/sfx/game/pause.wav')
  end

  def generate_asteroids(num)
    # Populate asteroids
    num.times do
      asteroid = Asteroid.new(rand(0..AsteritosWindow::WINDOW_WIDTH),
                              rand(0..AsteritosWindow::WINDOW_HEIGHT),
                              2)

      # Don't generate asteroids close enough to spawn-kill the player
      redo if Gosu.distance(@player.x, @player.y,
                            asteroid.x, asteroid.y) < MINIMUM_SHIP_DISTANCE

      @asteroids << asteroid
    end
  end

  def split_asteroid(asteroid)
    @asteroid_destroyed_sfx.play
    @score += 50

    # The asteroid is too small to split
    if (asteroid.size - 1).negative?
      @asteroids.delete(asteroid)
      return
    end

    @asteroids.push(Asteroid.new(asteroid.x, asteroid.y, asteroid.size - 1),
                    Asteroid.new(asteroid.x, asteroid.y, asteroid.size - 1))
    @asteroids.delete(asteroid)
  end

  def reset_player
    @player.x = AsteritosWindow::WINDOW_WIDTH / 2
    @player.y = AsteritosWindow::WINDOW_HEIGHT / 2
    @player.invulnerable!
  end

  def update(dt)
    if @pause
      @pause_text.update(dt)
      return
    end

    if @gameover
      update_gameover_screen
      return
    end

    @player.update(dt)
    @asteroids.each do |asteroid|
      asteroid.update(dt)
    end

    # Regenerate asteroids if necessary to keep the total asteroid
    # count equal to the required amount
    generate_asteroids(1) if (@asteroids.count + 1) < ASTEROIDS_AMOUNT

    player_collisions
    bullets_collisions
  end

  def button_down(key)
    @player.button_down(key)
    check_pause(key)
  end

  def check_pause(key)
    return unless key == Gosu::KB_RETURN && !@gameover

    # So when the pause starts the text will always be shown
    @pause_text.timer = 0.0
    @pause_text.blink = false

    @pause_sfx.play
    @pause = !@pause
  end

  def update_gameover_screen
    return unless Gosu.button_down?(Gosu::KB_RETURN)

    save_score
    @window.change_state(MenuState.new(@window), nil)
  end

  def player_collisions
    colliding_asteroid = @asteroids.find { |asteroid| collision?(@player, asteroid) }

    if colliding_asteroid && !@player.invulnerable?
      @player_destroyed_sfx.play
      split_asteroid(colliding_asteroid)

      if @lives.zero?
        @gameover = true
      else
        @lives -= 1
        reset_player
      end
    end
  end

  # Check collision between bullets and asteroids
  def bullets_collisions
    @player.bullets.any? do |bullet|
      @asteroids.any? do |asteroid|
        if collision?(bullet, asteroid)
          @player.bullets.delete(bullet)
          split_asteroid(asteroid)
        end
      end
    end
  end

  # Collision between circles
  def collision?(obj1, obj2)
    dist_x = obj1.x - obj2.x
    dist_y = obj1.y - obj2.y

    dist = Math.sqrt((dist_x * dist_x) + (dist_y * dist_y))

    return dist <= obj1.radius + obj2.radius
  end

  def draw
    @bg.draw(0, 0, 0)

    @player.draw
    @asteroids.each(&:draw)

    draw_hud
    draw_pause if @pause
    draw_gameover if @gameover
  end

  def draw_hud
    # TODO: Automatically center the avalues

    # Highlight to red the score  if its higher than the highscore
    score_color = @score > @highscore ? Gosu::Color::RED : Gosu::Color::WHITE

    @font.draw_text('LIVES', 20, 20, 0)
    @font.draw_text(@lives.to_s, 40, 35, 0)

    @font.draw_text('SCORE', 100, 20, 0)
    @font.draw_text(@score.to_s, 120, 35, 0, 1.0, 1.0, score_color)

    if @highscore
      @font.draw_text('HIGH-SCORE', 180, 20, 0)
      @font.draw_text(@highscore.to_s, 220, 35, 0)
    end

    @font.draw_text(Gosu.fps.to_s,
                    AsteritosWindow::WINDOW_WIDTH - @font.text_width(Gosu.fps.to_s) - 3,
                    AsteritosWindow::WINDOW_HEIGHT - @font.height,
                    0)
  end

  def draw_pause
    @pause_text.draw((AsteritosWindow::WINDOW_WIDTH / 2) - (@pause_text.w / 2),
                     (AsteritosWindow::WINDOW_HEIGHT / 4) - (@pause_text.h / 2),
                     0)
  end

  def draw_gameover
    msg = 'Game Over!, Press ENTER to go back to the menu'
    scale = 1.0

    width = @font.text_width(msg) * scale
    height = @font.height * scale

    @font.draw_text(msg,
                    (AsteritosWindow::WINDOW_WIDTH / 2) - (width / 2),
                    (AsteritosWindow::WINDOW_HEIGHT / 2) - (height / 2),
                    0,
                    scale, scale)
  end

  def save_score
    Dir.mkdir('data') unless Dir.exist?('data')

    File.write('data/score.txt', @score) if @score > @highscore
  end
end

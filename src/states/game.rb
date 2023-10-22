
require_relative '../state'

require_relative '../entities/ship'
require_relative '../entities/asteroid'

class GameState < State
  MINIMUM_SHIP_DISTANCE = 250
  INV_SECONDS = 3
  ASTEROIDS = 6

  # TODO: Change the game based on the options
  def enter(options)
    unless options.nil?
      @options = options
    end
  end

  def initialize(window)
    default_options = {lives: 3,
                       difficulty: :normal}

    @options = default_options

    @window = window

    @score = 0
    @lives = @options[:lives]
    @gameover = false

    @font = Gosu::Font.new(19, name: 'assets/fonts/nordine/nordine.ttf')

    @player = Ship.new(AsteritosWindow::WINDOW_WIDTH / 2,
                       AsteritosWindow::WINDOW_HEIGHT / 2)
    @asteroids = []
    @bg = Gosu::Image.new('assets/sprites/bg.png')

    @timer_inv = 0

    generate_asteroids(ASTEROIDS)
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

  def reset_player
    @player = Ship.new(AsteritosWindow::WINDOW_WIDTH / 2,
                       AsteritosWindow::WINDOW_HEIGHT / 2)
    @player.invulnerable = true
  end

  def split_asteroid(asteroid)
    if (asteroid.size - 1).negative?
      @asteroids.delete(asteroid)
      return
    end

    @asteroids.push(Asteroid.new(asteroid.x, asteroid.y, asteroid.size - 1),
                    Asteroid.new(asteroid.x, asteroid.y, asteroid.size - 1))
    @asteroids.delete(asteroid)
  end

  def update(dt)
    if @gameover
      update_gameover_screen
      return
    end

    @player.update(dt)

    @asteroids.each do |asteroid|
      asteroid.update(dt)
    end

    asteroids_spawn_update

    player_collisions
    bullets_collisions

    update_timer(dt)
  end

  def button_down(key)
    @player.button_down(key)
  end

  def update_gameover_screen
    if Gosu.button_down?(Gosu::KB_RETURN)
      @window.change_state(MenuState.new(@window), nil)
    end
  end

  def asteroids_spawn_update
    if (@asteroids.count + 1) < ASTEROIDS
      generate_asteroids(1)
    end
  end

  def player_collisions
    if @asteroids.any? { |asteroid| collision?(@player, asteroid) } && !@player.invulnerable
      if @lives.zero?
        @gameover = true
      else
        @lives -= 1
        reset_player
      end
    end
  end

  def bullets_collisions
    @player.bullets.any? do |bullet|
      @asteroids.any? do |asteroid|
        if collision?(bullet, asteroid)
          @player.bullets.delete(bullet)
          split_asteroid(asteroid)

          # TODO: Save highscore
          @score += 50
        end
      end
    end
  end

  def update_timer(dt)
    @timer_inv += dt if @player.invulnerable

    if @timer_inv >= INV_SECONDS
      @player.invulnerable = false
      @timer_inv = 0
    end
  end

  def collision?(obj1, obj2)
    dist_x = obj1.x - obj2.x
    dist_y = obj1.y - obj2.y

    dist = Math.sqrt((dist_x * dist_x) + (dist_y * dist_y))

    return dist <= obj1.radius + obj2.radius
  end

  def draw
    @bg.draw(0, 0, 0)

    @player.draw
    @asteroids.each do |asteroid|
      asteroid.draw
    end

    draw_hud
    draw_gameover if @gameover
  end

  def draw_hud
    @font.draw_text("LIVES", 20, 20, 0)
    @font.draw_text(@lives.to_i, 40, 30, 0)

    @font.draw_text("SCORE", 80, 20, 0)
    @font.draw_text(@score.to_i, 100, 30, 0)
  end

  def draw_gameover
    msg = "Game Over!, Press ENTER to go back to the menu"

    width = @font.text_width(msg) * 1.4

    @font.draw_text(msg,
                    (AsteritosWindow::WINDOW_WIDTH / 2) - (width / 2),
                    (AsteritosWindow::WINDOW_HEIGHT / 2) - ((18 * 1.4) / 2),
                    1.4, 1.4)
  end
end

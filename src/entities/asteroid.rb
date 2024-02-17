require 'mruby_compatibility'

class Asteroid
  attr_accessor :velocity, :size
  attr_reader :x, :y, :w, :h, :radius

  MINIMUM_VELOCITY = 50
  MAXIMUM_VELOCITY = 150
  ASTEROID_SPRITES = [Gosu::Image.new('assets/sprites/asteroid_1.png', retro: true),
                      Gosu::Image.new('assets/sprites/asteroid_2.png', retro: true),
                      Gosu::Image.new('assets/sprites/asteroid_3.png', retro: true)].freeze

  def initialize(x, y, size)
    @sprite = ASTEROID_SPRITES.sample

    @x = x
    @y = y
    @w = @sprite.width
    @h = @sprite.height
    @radius = 32

    @size_scale = [0.35, 0.5, 0.8]
    @size = size

    @velocity = 0
    @direction = 0

    random_velocity(MINIMUM_VELOCITY, MAXIMUM_VELOCITY)
  end

  def random_velocity(min, max)
    @velocity = MRubyCompatibility.rand(min..max)
    @direction = MRubyCompatibility.rand(0..360)
  end

  def update(dt)
    @x += Gosu.offset_x(@direction, 2) * @velocity * dt
    @y += Gosu.offset_y(@direction, 2) * @velocity * dt

    update_size
    wrap_movement
  end

  # So smaller asteroids can collision correctly
  def update_size
    @w = @sprite.width * @size_scale[@size]
    @h = @sprite.height * @size_scale[@size]

    @radius = @w / 2
  end

  def wrap_movement
    # NOTE: substract the checks against the right and bottom bounds since we're
    #       drawing the asteroids with their origin as the center of their image

    # Left right
    if @x - (@w * 0.5) >= AsteritosWindow::WINDOW_WIDTH
      @x = 0
    elsif @x + @w <= 0
      @x = AsteritosWindow::WINDOW_WIDTH
    end

    # Up down
    if @y - (@h * 0.5) >= AsteritosWindow::WINDOW_HEIGHT
      @y = 0
    elsif @y + @h <= 0
      @y = AsteritosWindow::WINDOW_HEIGHT
    end
  end

  def draw
    @sprite.draw_rot(@x, @y, 0,
                     @direction, 0.5, 0.5,
                     @size_scale[@size], @size_scale[@size])
  end
end


require_relative 'bullet'

class Ship
  attr_accessor :invulnerable
  attr_reader :x, :y, :w, :h, :radius, :bullets

  SPEED = 100
  MANEUVERABILITY = 300
  FRICTION = 0.99

  MAX_BULLETS = 3

  def initialize(x, y)
    @sprite = Gosu::Image.new('assets/sprites/ship.png', retro: true)

    @x = x
    @y = y
    @w = @sprite.width
    @h = @sprite.height
    @radius = 16

    @invulnerable = false

    @x_vel = 0
    @y_vel = 0
    @direction = 360

    @bullets = []

    @invulnerability_timer = 0.0
    @invulnerability_color = Gosu::Color.new(100, 255, 255, 255)
  end

  def invulnerable!
    @invulnerable = true
    @invulnerability_timer = 0.0
  end

  def update(dt)
    movement(dt)
    update_bullets(dt)
    handle_input(dt)

    wrap_movement
  end

  def button_down(key)
    case key
    when Gosu::KB_SPACE
      shoot if (@bullets.count + 1) <= MAX_BULLETS
    end
  end

  def update_bullets(dt)
    @bullets.each do |bullet|
      bullet.update(dt)
    end

    # Trim bullet array
    @bullets.delete_if(&:dead?)
  end

  def handle_input(dt)
    if Gosu.button_down?(Gosu::KB_A)
      @direction -= MANEUVERABILITY * dt
    elsif Gosu.button_down?(Gosu::KB_D)
      @direction += MANEUVERABILITY * dt
    end

    thrust if Gosu.button_down?(Gosu::KB_W)
  end

  def movement(dt)
    @x += @x_vel * dt
    @y += @y_vel * dt

    @x_vel *= FRICTION
    @y_vel *= FRICTION
  end

  def wrap_movement
    # NOTE: substract the checks against the right and bottom bounds since we're
    #       drawing the ship with its origin as the center of the image

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

  def thrust
    @x_vel = Gosu.offset_x(@direction, 2) * SPEED
    @y_vel = Gosu.offset_y(@direction, 2) * SPEED
  end

  def shoot
    @bullets << Bullet.new(@x, @y, @direction)
  end

  def draw
    draw_bullets

    # TODO: Flashing
    if @invulnerable
      @sprite.draw_rot(@x, @y, 0,
                       @direction, 0.5, 0.5,
                       1.0, 1.0,
                       @invulnerability_color)
    else
      @sprite.draw_rot(@x, @y, 0, @direction)
    end
  end

  def draw_bullets
    @bullets.each(&:draw)
  end
end

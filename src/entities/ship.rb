
require_relative 'bullet'

class Ship
  attr_accessor :invulnerable
  attr_reader :x, :y, :w, :h, :radius, :bullets

  MANEUVERABILITY = 300
  FRICTION = 0.99
  MAX_BULLETS = 3

  def initialize(x, y)
    @sprite = Gosu::Image.new('assets/sprites/ship.png', retro: true)
    @inv_color = Gosu::Color.new(100, 255, 255, 255)

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
  end

  def update(dt)
    @x += @x_vel * dt
    @y += @y_vel * dt

    @x_vel *= FRICTION
    @y_vel *= FRICTION

    handle_input(dt)
    update_bullets(dt)
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
    @bullets.delete_if { |bullet| bullet.dead? }
  end

  def handle_input(dt)
    if Gosu.button_down?(Gosu::KB_A)
      @direction -= MANEUVERABILITY * dt
    elsif Gosu.button_down?(Gosu::KB_D)
      @direction += MANEUVERABILITY * dt
    end

    if Gosu.button_down?(Gosu::KB_W)
      move
    end
  end

  def wrap_movement
    # NOTE: substract the checks against the right and bottom bounds since we're
    #       drawing the ship with it's origin as the center of the image

    # Left right
    if @x - (@w * 0.5) >= AsteritosWindow::WINDOW_WIDTH
      @x = 0
    elsif @x + @w <= 0
      @x = AsteritosWindow::WINDOW_WIDTH
    end

    # Up down
    if @y - (@h * 0.5)>= AsteritosWindow::WINDOW_HEIGHT
      @y = 0
    elsif @y + @h <= 0
      @y = AsteritosWindow::WINDOW_HEIGHT
    end
  end

  def move
    @x_vel = Gosu.offset_x(@direction, 2) * 100
    @y_vel = Gosu.offset_y(@direction, 2) * 100
  end

  def shoot
    @bullets << Bullet.new(@x, @y, @direction)
  end

  def draw
    # TODO: Flashing
    unless @invulnerable
      @sprite.draw_rot(@x, @y, 0, @direction)
    else
      @sprite.draw_rot(@x, @y, 0,
                       @direction, 0.5, 0.5,
                       1.0, 1.0,
                       @inv_color)
    end

    draw_bullets
  end

  def draw_bullets
    @bullets.each do |bullet|
      bullet.draw
    end
  end
end

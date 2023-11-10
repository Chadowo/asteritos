
class Ship
  attr_accessor :x, :y, :invulnerable
  attr_reader :w, :h, :radius, :bullets

  SPEED = 100
  MANEUVERABILITY = 300
  FRICTION = 0.99

  MAX_BULLETS = 3
  INVULNERABILITY_DURATION = 3.0 # Seconds

  BLINK_INTERVAL = 0.2 # 200ms

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

    @blink_timer = 0.0
    @blink = false
  end

  def invulnerable?
    @invulnerable
  end

  def invulnerable!
    @invulnerable = true
    @invulnerability_timer = 0.0

    @blink = true
    @blink_timer = 0.0
  end

  def update(dt)
    handle_input(dt)
    movement(dt)

    update_bullets(dt)
    update_invulnerability_timer(dt) if @invulnerable
    update_blink_timer(dt) if @invulnerable

    wrap_movement
  end

  def button_down(key)
    case key
    when Gosu::KB_SPACE
      shoot if (@bullets.count + 1) <= MAX_BULLETS
    end
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

  def update_bullets(dt)
    @bullets.each do |bullet|
      bullet.update(dt)
    end

    # Trim bullet array
    @bullets.delete_if(&:dead?)
  end

  def update_invulnerability_timer(dt)
    @invulnerability_timer += dt

    @invulnerable = false if @invulnerability_timer >= INVULNERABILITY_DURATION
  end

  def update_blink_timer(dt)
    @blink_timer += dt

    if @blink_timer >= BLINK_INTERVAL
      @blink = !@blink
      @blink_timer = 0.0
    end
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

    if @invulnerable
      # Blink between being transparent and opaque
      color = @blink ? Gosu::Color::WHITE : @invulnerability_color

      @sprite.draw_rot(@x, @y, 0,
                       @direction, 0.5, 0.5,
                       1.0, 1.0,
                       color)
    else
      @sprite.draw_rot(@x, @y, 0, @direction)
    end
  end

  def draw_bullets
    @bullets.each(&:draw)
  end
end

require 'aniruby'
require 'controls'

class Ship
  attr_accessor :x, :y, :invulnerable
  attr_reader :w, :h, :radius, :bullets

  SPEED = 100
  MANEUVERABILITY = 300
  FRICTION = 0.99

  INVULNERABILITY_DURATION = 3.0
  BLINK_INTERVAL = 0.2

  MAX_BULLETS = 3

  def initialize(x, y)
    @idle_sprite = Gosu::Image.new('assets/sprites/ship.png', retro: true)
    @movement_anim = AniRuby::Animation.new('assets/sprites/ship_movement.png',
                                            32, 32, retro: true)
    @state = :idle

    @x = x
    @y = y
    @w = @idle_sprite.width
    @h = @idle_sprite.height
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

    @movement_anim.update if @state == :moving

    wrap_movement
  end

  def update_invulnerability_timer(dt)
    @invulnerability_timer += dt

    @invulnerable = false if @invulnerability_timer >= INVULNERABILITY_DURATION
  end

  def update_blink_timer(dt)
    @blink_timer += dt

    return unless @blink_timer >= BLINK_INTERVAL

    @blink = !@blink
    @blink_timer = 0.0
  end

  def button_down(key)
    shoot if Controls::FIRE.include?(key) && (@bullets.count + 1) <= MAX_BULLETS
  end

  def handle_input(dt)
    if Controls.pressed?(Controls::LEFT)
      @direction -= MANEUVERABILITY * dt
    elsif Controls.pressed?(Controls::RIGHT)
      @direction += MANEUVERABILITY * dt
    end

    if Controls.pressed?(Controls::UP)
      @state = :moving
      thrust
    else
      @state = :idle
    end
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
      draw_invulnerable
      return
    end

    case @state
    when :idle then @idle_sprite.draw_rot(@x, @y, 0, @direction)
    when :moving then @movement_anim.draw_rot(@x, @y, 0, @direction)
    end
  end

  def draw_invulnerable
    # Blink between being transparent and opaque
    color = @blink ? Gosu::Color::WHITE : @invulnerability_color

    case @state
    when :idle
      @idle_sprite.draw_rot(@x, @y, 0,
                            @direction, 0.5, 0.5,
                            1.0, 1.0, color)
    when :moving
      @movement_anim.draw_rot(@x, @y, 0,
                              @direction, 0.5, 0.5,
                              1.0, 1.0, color)
    end
  end

  def draw_bullets
    @bullets.each(&:draw)
  end
end

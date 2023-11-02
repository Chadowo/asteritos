
class Bullet
  attr_reader :x, :y, :w, :h, :radius

  BULLET_SPEED = 250

  def initialize(x, y, direction)
    @sprite = Gosu::Image.new('assets/sprites/bullet.png', retro: true)

    @x = x
    @y = y
    @w = @sprite.width
    @h = @sprite.height
    @radius = 4

    @velocity = 0
    @direction = direction

    @dead = false
  end

  def dead?
    return true if @dead

    false
  end

  def update(dt)
    @x += Gosu.offset_x(@direction, 2) * BULLET_SPEED * dt
    @y += Gosu.offset_y(@direction, 2) * BULLET_SPEED * dt

    if @x + @w >= AsteritosWindow::WINDOW_WIDTH ||
       @x <= 0 ||
       @y + @h >= AsteritosWindow::WINDOW_HEIGHT ||
       @y <= 0
    then
      @dead = true
    end
  end

  def draw
    @sprite.draw_rot(@x, @y, 0, @direction)
  end
end

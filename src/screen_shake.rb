class ScreenShake
  attr_reader :dx, :dy

  def initialize(time, intensity, speed = 0.1)
    @original_time = time
    @original_intensity = intensity

    @timer = time
    @speed_timer = speed

    @intensity = intensity

    @speed = speed
    @direction = 1

    @dx = 0
    @dy = 0
  end

  def finished?
    true if @timer.negative? && @intensity.negative?
  end

  def reset
    @timer = @original_time
    @speed_timer = @speed
    @intensity = @original_intensity
  end

  def update(dt)
    return if finished?

    @timer -= dt
    @speed_timer -= dt

    @dx = @intensity * @direction

    # Change direction when the speed timer's up
    if @speed_timer.negative?
      @direction *= -1
      @speed_timer = @speed
    end

    # Fade intensity when the shake timer is up
    @intensity -= (dt * 10) if @timer.negative?
  end
end

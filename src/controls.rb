# Contains the keybindings for each action in the
# game. All the keybindings are stored as Sets,
# to keep uniformity between actions with multiple
# keybindings and others with one
module Controls
  UP = Set[Gosu::KB_W, Gosu::KB_UP]
  DOWN = Set[Gosu::KB_S, Gosu::KB_DOWN]
  LEFT = Set[Gosu::KB_A, Gosu::KB_LEFT]
  RIGHT = Set[Gosu::KB_D, Gosu::KB_RIGHT]
  FIRE = Set[Gosu::KB_SPACE]
  ENTER = Set[Gosu::KB_RETURN]
  CLOSE = Set[Gosu::KB_ESCAPE]

  # Return whether the keybinding is pressed or not, the keybinding
  # can have multiple keys
  def pressed?(keybinding)
    if keybinding.one?
      Gosu.button_down?(keybinding.to_a.first)
    elsif keybinding.any? { |key| Gosu.button_down?(key) }
      true
    end
  end

  module_function :pressed?
end

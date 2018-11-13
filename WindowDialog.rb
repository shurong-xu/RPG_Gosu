class WindowDialog < WindowBase
  def initialize(game, texts=[])
    @game = game
    super(@game, 160, 320, GameMain::WINDOW_Z, 448, 128, texts, false, false)
    @active = false
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      @active = false
      @game.scene.map.active = true
    end
  end
end
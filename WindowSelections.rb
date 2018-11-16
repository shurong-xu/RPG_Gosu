class WindowSelections < WindowSelectable
  attr_accessor :options
  def initialize(game, options=[])
    @game = game
    @options = []
    super(@game, 192, 192, GameMain::WINDOW_Z, 224, 32, @options, 1)
    @active = false
  end

  def button_down(id)
    case id
    when Gosu::MS_LEFT
      if @index >= 0
        @game.selection = @index
        @game.scene.map.active = true
        @active = false
      end
    end
  end
end
class WindowStatus < WindowBase
  def initialize(game, x, y, z, width, height, texts, active, scroll_active)
    @game = game
    super(@game, x, y, z, width, height, texts, active, scroll_active)
  end

  def update
    @x -= 30 if @x > 160
  end
end
class WindowGameDate < WindowBase
  def initialize(game, game_date)
    @game = game
    @game_date = game_date
    super(@game, 0, 0, GameMain::WINDOW_Z, 128, 32, [], true)
  end

  def update
    @texts = [@game_date.to_string]
  end

end

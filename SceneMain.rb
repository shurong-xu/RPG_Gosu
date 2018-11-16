class SceneMain
  attr_accessor :map, :actor, :window_dialog, :window_game_date, :window_selections
  def initialize(game, game_date)
		@game = game
		@game_date = game_date
    @map = Map.new(@game, GameMain::MAP_Z, 'map3')
    @actor = Actor.new(@game, 'Actor', 0, 'xsrong', 320, 448, GameMain::EVENTS_Z)
    @window_dialog =  WindowDialog.new(@game)
    @window_game_date = WindowGameDate.new(@game, @game.game_date)
    @window_selections = WindowSelections.new(@game)
  end

  def draw
    @map.draw
		@actor.draw
    @window_dialog.draw if @window_dialog.active
    @window_game_date.draw if @window_game_date.active
    @window_selections.draw if @window_selections.active
  end

  def update(mouse_x, mouse_y)
    if @map.active
      @map.update(mouse_x, mouse_y)
      @window_game_date.update
    end
    @window_selections.update(mouse_x, mouse_y) if @window_selections.active
    @actor.update
  end

  def button_down(mouse_x, mouse_y, id)
    if @window_dialog.active
      @window_dialog.button_down(id)
    elsif @window_selections.active
      @window_selections.button_down(id)
    else
      @map.button_down(mouse_x, mouse_y, id)
    end
  end

end
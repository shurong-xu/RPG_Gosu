class SceneMain
  attr_accessor :map, :actor, :window_dialog
  def initialize(game)
    @game = game
    @map = Map.new(@game, GameMain::MAP_Z, 'map1')
    @actor = Actor.new(@game, 'Actor1', 0, 'xsrong', 64, 32, GameMain::EVENTS_Z)
    @window_dialog =  WindowDialog.new(@game)
  end

  def draw
    @map.draw
    @actor.draw
    @window_dialog.draw if @window_dialog.active
  end

  def update(mouse_x, mouse_y)
    @map.update(mouse_x, mouse_y) if @map.active
    @actor.update
  end

  def button_down(mouse_x, mouse_y, id)
    if @window_dialog.active
      @window_dialog.button_down(id)
    else
      @map.button_down(mouse_x, mouse_y, id)
    end
  end

end
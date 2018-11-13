class Mouse
  attr_accessor :img, :normal, :dialog
  def initialize(game)
    @game = game
    @normal = Gosu::Image.new('Graphics/Mouse/normal.bmp')
    @dialog = Gosu::Image.new('Graphics/Mouse/dialog.bmp')
    @img = @normal
  end

  def draw(x, y)
    @img.draw(x-@img.width/2, y-@img.height/2, GameMain::MOUSE_Z) if @img
  end

  def update(x, y)
    @game.scene.map.events.each do |event|
      if event.active2 && event.self_switch && event.mouse_on?(x, y)
        @img = @dialog
        break
      else
        @img = @normal
      end
    end
  end

end
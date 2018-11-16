class Mouse
  attr_accessor :img, :normal, :dialog
  def initialize(game)
    @game = game
    folder_path = 'Graphics/Mouse/'
    @normal = Gosu::Image.new(folder_path + 'normal.bmp')
    @dialog = Gosu::Image.new(folder_path + 'dialog.bmp')
    @get_item = Gosu::Image.new(folder_path + 'get_item.bmp')
    @img = @normal
  end

  def draw(x, y)
    @img.draw(x-@img.width/2, y-@img.height/2, GameMain::MOUSE_Z) if @img
  end

  def update(x, y)
    @game.scene.map.events.each do |event|
      if event.active2 && event.self_switch && event.mouse_on?(x, y)
        if event.event_type == :npc
          @img = @dialog 
        elsif event.event_type == :box
          @img = @get_item 
        end
        break
      else
        @img = @normal
      end
    end
  end

end
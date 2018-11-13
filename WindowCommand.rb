class WindowCommand < WindowSelectable
  def initialize(game, x, y, z, width, height)
    @game = game
    @commands = ['物品', '存档', '退出']
    super(@game, x, y, z, width, height / @commands.length, @commands)
  end

  def update
    super
    @x += 10 if @x < 0
  end

  def button_down(id)
    super
    case id
    when Gosu::MS_LEFT
      case @index
      when 2
        @game.close
      else
        p @index
      end
    end
  end
end
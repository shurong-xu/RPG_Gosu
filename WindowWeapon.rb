class WindowWeapon < WindowSelectable
  def initialize(game, x, y, z, width)
    weapons = ['fire slade', 'fire slade', 'fire slade', 'fire slade', 'fire slade', 'fire slade', 'fire slade'] * 100
    @game = game
    super(@game, x, y, z, width, 64, weapons, 4)
    @font_size = 16
    @font = Gosu::Font.new(@font_size, name:'Microsoft YaHei')
  end
end
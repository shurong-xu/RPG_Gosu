module Tileset
  def self.load_map(game, filename)
    @line = File.readlines(filename).map { |line| line.chomp }
    @height = @line.size - 1
    @width = @line[1].split(",").size
    @tiles= self.load_tiles
    return @tiles
  end
  
  def self.load_tiles
    tiles = Array.new(@width) do |x|
      Array.new(@height) do |y|
        text = @line[y + 1].split(",")[x]
        case text
        when '###'
          nil
        else
          text.to_i
        end #case
      end
    end
      return tiles
  end
end

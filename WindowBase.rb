class WindowBase
  WHITE = Gosu::Color.new(255, 255, 255, 255)
  BLUE_BORDER = Gosu::Color.new(255, 33, 35, 79)
  BLUE1 = Gosu::Color.new(255, 66, 68, 120)
  BLUE2 = Gosu::Color.new(255, 56,58, 110)
  BLUE3 = Gosu::Color.new(255, 40, 41, 81) 
  BLUE_TEXT = Gosu::Color.new(255, 192, 224, 255) 
  GREEN_LIGHT = Gosu::Color.new(255, 0, 255, 0)
  GREEN_DARK = Gosu::Color.new(255, 0, 100, 0)
  BLUE_LIGHT = Gosu::Color.new(255, 0, 0, 255)
  BLUE_DARK = Gosu::Color.new(255, 0, 0, 100)
  BLACK = Gosu::Color.new(255, 0, 0, 0)
  GREY = Gosu::Color.new(255, 50, 50, 50)
  RED_DARK = Gosu::Color.new(255, 255, 0, 0)
  RED_LIGHT = Gosu::Color.new(255, 255, 104, 104)
  attr_accessor :x, :y, :z, :width, :height, :texts, :active
  def initialize(game, x, y, z, width, height, texts=[], active=false, scroll_active=false)
    @game = game
    @x, @y, @z = x, y, z
    @width, @height = width, height
    @camera_y = 0
    @cursor_opacity_scroll = 0
    @texts = texts
    @font_size = 16
    @font = Gosu::Font.new(@font_size, name:'Microsoft YaHei')
    @active = active
    @active = true
    @scroll_active = scroll_active
  end

  def draw
    height = [@height, @game.height].min
    @game.draw_quad(@x, @y, WHITE, 
      @x + @width, @y, WHITE, 
      @x + @width, @y + height, WHITE, 
      @x, @y + height, WHITE, 
      @z)
    @game.draw_quad(@x + 3, @y + 3, BLUE1, 
      @x + @width - 3, @y + 3, BLUE1, 
      @x + @width - 3, @y + height - 3, BLUE1, 
      @x + 3, @y + height - 3, BLUE1, 
      @z + 1)
    draw_texts
    draw_scroll if @scroll_active
  end

  def button_down(id)
    case id
    when Gosu::MS_WHEEL_DOWN
      @camera_y += 16 if @scroll_active && @camera_y < @texts.length * @font_size - @height + 20
      @cursor_opacity_scroll = 305
    when Gosu::MS_WHEEL_UP
      @camera_y -= 16  if @scroll_active && @camera_y > 0
      @cursor_opacity_scroll = 305
    end
  end

  def draw_scroll
    h = @height * 0.6
    @h_bar = [h, (@height - 20) / (@texts.length * @font_size).to_f * h].min
    @y_bar = @y + @height * 0.2 + @camera_y.to_f / (@texts.length * @font_size) * h
    @cursor_opacity_scroll -= 5 if @cursor_opacity_scroll > 0
    @game.draw_quad(@x + @width * 0.9, @y + @height * 0.2, Gosu::Color.new(@cursor_opacity_scroll, 255, 255, 255), 
      @x + @width * 0.95, @y + @height * 0.2, Gosu::Color.new(@cursor_opacity_scroll, 255, 255, 255), 
      @x + @width * 0.95, @y + @height * 0.2 + h, Gosu::Color.new(@cursor_opacity_scroll, 255, 255, 255), 
      @x + @width * 0.9, @y + @height * 0.2 + h, Gosu::Color.new(@cursor_opacity_scroll, 255, 255, 255), 
      89)
    @game.draw_quad(@x + @width * 0.9 + 1, @y + @height * 0.2 + 1, Gosu::Color.new(@cursor_opacity_scroll, 0, 0, 0), 
      @x + @width * 0.95 - 1,  @y + @height * 0.2 + 1, Gosu::Color.new(@cursor_opacity_scroll, 0, 0, 0), 
      @x + @width * 0.95 - 1, @y + @height * 0.2 + h - 1, Gosu::Color.new(@cursor_opacity_scroll, 0, 0, 0), 
      @x + @width * 0.9 + 1, @y + @height * 0.2 + h - 1, Gosu::Color.new(@cursor_opacity_scroll, 0, 0, 0), 
      90)
    @game.draw_quad(@x + @width * 0.9, @y_bar, Gosu::Color.new(@cursor_opacity_scroll-50, 255, 255, 255), 
      @x + @width * 0.95, @y_bar, Gosu::Color.new(@cursor_opacity_scroll-50, 255, 255, 255), 
      @x + @width * 0.95, @y_bar + @h_bar, Gosu::Color.new(@cursor_opacity_scroll-50, 255, 255, 255), 
      @x + @width * 0.9, @y_bar + @h_bar, Gosu::Color.new(@cursor_opacity_scroll-50, 255, 255, 255), 
      95)
  end

  def draw_texts
    for i in 0..@texts.length - 1
      @font.draw(@texts[i], @x + 10, @y + 10 + i * @font_size - @camera_y, 99) if @y + 10 + (i + 1) * @font_size - @camera_y < @y + @height
    end
  end

  def update
  end

  def get_index(x, y)
  end
end
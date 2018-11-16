class WindowSelectable < WindowBase
  def initialize(game, x, y, z, width, line_height, options, column_num=1)
    @index = -1
    @options = options
    @column_num = column_num
    @line_height = line_height
    height = (@options.length.to_f / @column_num).ceil * @line_height
    @cursor_opacity = 20
    @fading_type = :IN
    super(game, x, y, z, width, height, [], false, false)
  end

  def draw
    super
    for i in 0..@options.length - 1
      @font.draw_rel(@options[i], @x + @width / @column_num * (i % @column_num + 0.5), (@y - @camera_y + @height / (@options.length.to_f / @column_num).ceil / 2 + i / @column_num * @line_height),  @z + 5, 0.5, 0.5) if @x >= 0 && @y >= 0
    end
    draw_index if @index >= 0 && @x >= 0 && @y >= 0
  end

  def update(mouse_x, mouse_y)
    @height = (@options.length.to_f / @column_num).ceil * @line_height
    get_index(mouse_x, mouse_y)
  end

  def get_index(x, y)
    @index = -1
    if @active && x > @x && x < @x + @width && y > @y && y < @y + @height
      index_x = ((x - @x) / (@width / @column_num)).floor
      index_y = ((y - @y + @camera_y) / @line_height).floor
      @index = index_x + index_y * @column_num
      @index = -1 if @index > @options.length - 1
    end
  end

  def draw_index
    blue_border = Gosu::Color.new(@cursor_opacity, 192, 224, 255)
    blue2 = Gosu::Color.new(@cursor_opacity, 44, 45, 85)
    width = @width / @column_num
    x = @x + (@index % @column_num) * width
    y = @y + @index / @column_num  * @line_height - @camera_y
    @game.draw_quad(x + 5, y + 5, blue_border, x + width - 5, y + 5, blue_border, x + width - 5, y + @line_height - 5, blue_border, x + 5, y + @line_height - 5, blue_border, @z + 9)          
    @game.draw_quad(x + 6, y + 6, blue2, x + width - 6, y + 6, blue2, x + width - 6, y + @line_height - 6, blue2, x + 6, y + @line_height - 6, blue2, @z + 10)

    @cursor_opacity += 5 if @fading_type == :IN
    @cursor_opacity -= 5 if @fading_type == :OUT

    @fading_type = :OUT if @cursor_opacity >= 160
    @fading_type = :IN if @cursor_opacity <= 20
  end

  def draw_scroll
    h = @game.height * 0.6
    @h_bar = [h, @game.height / @height.to_f * h].min
    @y_bar = @y + @game.height * 0.2 + @camera_y.to_f / @height * h
    @cursor_opacity_scroll -= 5 if @cursor_opacity_scroll > 0
    @game.draw_quad(@x + @width * 0.9, @y + @game.height * 0.2, Gosu::Color.new(@cursor_opacity_scroll, 255, 255, 255), 
      @x + @width * 0.95, @y + @game.height * 0.2, Gosu::Color.new(@cursor_opacity_scroll, 255, 255, 255), 
      @x + @width * 0.95, @y + @game.height * 0.2 + h, Gosu::Color.new(@cursor_opacity_scroll, 255, 255, 255), 
      @x + @width * 0.9, @y + @game.height * 0.2 + h, Gosu::Color.new(@cursor_opacity_scroll, 255, 255, 255), 
      89)
    @game.draw_quad(@x + @width * 0.9 + 1, @y + @game.height * 0.2 + 1, Gosu::Color.new(@cursor_opacity_scroll, 0, 0, 0), 
      @x + @width * 0.95 - 1,  @y + @game.height * 0.2 + 1, Gosu::Color.new(@cursor_opacity_scroll, 0, 0, 0), 
      @x + @width * 0.95 - 1, @y + @game.height * 0.2 + h - 1, Gosu::Color.new(@cursor_opacity_scroll, 0, 0, 0), 
      @x + @width * 0.9 + 1, @y + @game.height * 0.2 + h - 1, Gosu::Color.new(@cursor_opacity_scroll, 0, 0, 0), 
      90)
    @game.draw_quad(@x + @width * 0.9, @y_bar, Gosu::Color.new(@cursor_opacity_scroll-50, 255, 255, 255), 
      @x + @width * 0.95, @y_bar, Gosu::Color.new(@cursor_opacity_scroll-50, 255, 255, 255), 
      @x + @width * 0.95, @y_bar + @h_bar, Gosu::Color.new(@cursor_opacity_scroll-50, 255, 255, 255), 
      @x + @width * 0.9, @y_bar + @h_bar, Gosu::Color.new(@cursor_opacity_scroll-50, 255, 255, 255), 
      95)
  end

  def button_down(id)
    case id
    when Gosu::MS_WHEEL_DOWN
      @camera_y += 16 if @camera_y < @height - @game.height
      @cursor_opacity_scroll = 305
    when Gosu::MS_WHEEL_UP
      @camera_y -= 16  if @camera_y > 0
      @cursor_opacity_scroll = 305
    when Gosu::MS_LEFT
      p @index
    end
  end

end
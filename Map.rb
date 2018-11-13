class Map
  attr_accessor :width, :height, :map_id, :camera_x, :camera_y, :active, :events, :cur_event
  def initialize(game, z, map_id, camera_x=0, camera_y=0)
    @game = game
    @z = z
    @map_id = 'Maps\\' + map_id
    @tiles_low = Tileset.load_map(@game, @map_id + "_low.txt")
    @tiles_mid = Tileset.load_map(@game, @map_id + "_mid.txt")
    @tiles_hig = Tileset.load_map(@game, @map_id + "_hig.txt")
    tileset_filename = "Graphics/Tilesets/" + File.readlines(@map_id + "_low.txt")[0].chomp + ".png"
    @tileset = Gosu::Image.load_tiles(tileset_filename, 32, 32, :tileable => false)
    @solid_blocks = Tileset.load_map(@game, @map_id + "_sld.txt")
    @width = @tiles_low.size
    @height = @tiles_low[0].size
    @camera_x = camera_x
    @camera_y = camera_y
    @active = true
    @mark_cursor_opacity = 0
    @mark_x = @mark_y = 0
    events = File.readlines(@map_id + '_sld.txt')[0].chomp.split(',')
    @events = []
    events.each do |e|
      @events << Event.new(@game, e)
    end
    @cur_event = nil
  end

  def draw
    @height.times do |y|
      @width.times do |x|
        tile1 = @tiles_low[x][y]
        tile2 = @tiles_mid[x][y]
        tile3 = @tiles_hig[x][y]
        @tileset[tile1].draw(x * 32 - @camera_x, y * 32 - @camera_y, @z) if tile1
        @tileset[tile2].draw(x * 32 - @camera_x, y * 32 - @camera_y, @z + 1) if tile2
        @tileset[tile3].draw(x * 32 - @camera_x, y * 32 - @camera_y, @z + 2) if tile3
      end
    end
    @events.each do |event|
      event.draw if event.active2 && event.self_switch
    end
    draw_mark([@mark_x, @mark_y])
  end

  def update(mouse_x, mouse_y)
    actor = @game.scene.actor
    @events.each do |event|
      event.update(actor, mouse_x, mouse_y) if !event.active
      if event.active2 && event.self_switch && event.exe_type == :auto
        eval(event.cmds[event.cmd_idx])
        event.cmd_idx += 1
        event.cmd_idx = 1 if event.cmd_idx == event.cmds.length 
      elsif event.active2 && event.self_switch && event.exe_type == :over_on && event.cmd_idx != event.cmds.length
        if event.x == actor.x && event.y == actor.y
          eval(event.cmds[event.cmd_idx])
          event.cmd_idx += 1
          event.cmd_idx = 1 if event.cmd_idx == event.cmds.length
        end
      elsif event.active2 && event.self_switch && event.exe_type == :close_to_actor && event.cmd_idx != event.cmds.length
        if ((event.x - actor.x).abs <= 32 && event.y == actor.y) || ((event.y - actor.y).abs <= 32 && event.x == actor.x) && event.is_face_to_actor?(actor)
          event.path = []
          actor.path = []
          event.face_to_actor(actor)
          event.event_pose
          eval(event.cmds[event.cmd_idx])
          event.cmd_idx += 1
          event.cmd_idx = 1 if event.cmd_idx == event.cmds.length
        end
      elsif event.active2 && event.self_switch && event.exe_type == :click && @cur_event && event == @cur_event && event.cmd_idx != event.cmds.length
        @cur_event.face_to_actor(actor)
        @cur_event.event_pose
        if @cur_event.cmd_idx < @cur_event.cmds.length
          eval(@cur_event.cmds[@cur_event.cmd_idx])
          @cur_event.cmd_idx += 1
        else
          @cur_event.cmd_idx = 1
        end
      end
    end
  end

  def button_down(mouse_x, mouse_y, id)
    case id
    when Gosu::MS_LEFT
      if @active
        @events.each do |event|
          @cur_event = event.choose_event(mouse_x, mouse_y)
          if @cur_event != nil
            @cur_event.cmd_idx = 1
            break
          end
        end
      end
      actor = @game.scene.actor
      if !@cur_event
        start = [actor.x / 32, actor.y / 32]
        desti = [((mouse_x + @camera_x) / 32).floor, ((mouse_y + @camera_y) / 32).floor]
        path = bfs(start, desti)
        actor.ending_face_to = nil
        actor.path = path
        if path.length != 0
          @mark_cursor_opacity = 255
          @mark_x = desti[0]
          @mark_y = desti[1]
        end
      end
    end
  end
  
  def is_solid?(x, y)
    return true if x < 0 || x > @width - 1 || y < 0 || y > @height - 1 || @solid_blocks[x][y] == 1
    return false
  end

  def to_block_index(map_x, map_y)
    index = -1
    if map_x >= 0 && map_x < @width && map_y >= 0 && map_y < @height
      index = map_x % @width
      index += map_y * @width
    end
    return index
  end

  def to_block_xy(index)
    if index >= 0
      x = index % @width
      y = index / @width
      if x >= 0 && x < @width && y >= 0 && y < @height
        return [x, y]
      else
        return nil
      end
    end
    return nil
  end

  def around(map_x, map_y)
    arr = []
    arr << to_block_index(map_x, map_y - 1)
    arr << to_block_index(map_x + 1, map_y)
    arr << to_block_index(map_x, map_y + 1)
    arr << to_block_index(map_x - 1, map_y)
    return arr
  end

  def bfs(start, desti, first_direct=:up)
    desti_arr = []
    while is_solid?(desti[0], desti[1])
      desti_arr += around(desti[0], desti[1])
      desti_idx = desti_arr.shift
      desti = to_block_xy(desti_idx)
    end
    marked = []
    queue = []
    path_to = []
    path = []
    start_idx = to_block_index(start[0], start[1])
    desti_idx = to_block_index(desti[0], desti[1])
    marked << start_idx
    queue << start_idx
    while !marked.include?(desti_idx) && marked.length < 1000
      new_start_idx = queue.shift
      new_start = to_block_xy(new_start_idx)
      around_arr = around(new_start[0], new_start[1])
      case first_direct
      when :down
        around_arr[2], around_arr[0] = around_arr[0], around_arr[2]
        around_arr[2], around_arr[3] = around_arr[3], around_arr[2]
      when :right
        around_arr[1], around_arr[0] = around_arr[0], around_arr[1]
      when :left
        around_arr[3], around_arr[0] = around_arr[0], around_arr[3]
        around_arr[2], around_arr[3] = around_arr[3], around_arr[2]
      when :up
        around_arr[2], around_arr[3] = around_arr[3], around_arr[2]
      end
      around_arr.each do |e|
        if e != -1 && !marked.include?(e)
          e_xy = to_block_xy(e)
          if !is_solid?(e_xy[0], e_xy[1])
            marked << e
            queue << e
            path_to[e] = new_start_idx
          end
        end
      end
    end
    if marked.include?(desti_idx)
      while desti_idx != start_idx
        path.unshift(desti_idx)
        desti_idx = path_to[desti_idx]
      end
    end
    for i in 0..path.length - 1
      path[i] = to_block_xy(path[i]) if path.length != 0
    end
    return path
  end

  def draw_mark(desti)
    color = Gosu::Color.new(@mark_cursor_opacity, 255, 255, 255)
    @game.draw_triangle(desti[0]*32 - @camera_x, desti[1]*32 - @camera_y, color, desti[0]*32 + 32 - @camera_x, desti[1]*32 - @camera_y, color, desti[0]*32 + 16 - @camera_x, desti[1]*32 + 32 - @camera_y, color, @z + 5)
    @mark_cursor_opacity -= 5 if @mark_cursor_opacity > 0
  end
end
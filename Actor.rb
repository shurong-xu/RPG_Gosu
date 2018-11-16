class Actor
  attr_accessor :name, :x, :y, :face_to, :ending_face_to, :move_speed, :path, :status, :famous, :haogan
  def initialize(game, charaset_filename, charaset_idx, name, x, y, z)
    @game = game
    @name = name
    @x, @y, @z = x, y, z
    charaset_filename = 'Graphics/Charasets/' + charaset_filename + '.png'
    @tileset = Gosu::Image.load_tiles(charaset_filename, 32, 32)
    @charaset_idx = charaset_idx
    @face_to = :left
    @ending_face_to = nil
    @move_speed = 2
    @path = []
    @haogan = [0] * 999
    @famous = 0
    @status = :ahead
  end

  def update
    actor_pose
    move_in_path
  end

  def draw
    @cur_image.draw(@x - @game.scene.map.camera_x, @y - @game.scene.map.camera_y, @z)
  end

  def actor_pose
    case @status
    when :ahead
      case @face_to
      when :down
        @walking1, @standing1, @walking2 = @tileset[@charaset_idx..@charaset_idx + 2]
      when :right
        @walking1, @standing1, @walking2 = @tileset[@charaset_idx + 3..@charaset_idx + 5]
      when :left
        @walking1, @standing1, @walking2 = @tileset[@charaset_idx + 6..@charaset_idx + 8]
      when :up
        @walking1, @standing1, @walking2 = @tileset[@charaset_idx + 9..@charaset_idx + 11]
      end
    when :back
      case @face_to
      when :up
        @walking1, @standing1, @walking2 = @tileset[@charaset_idx..@charaset_idx + 2]
      when :left
        @walking1, @standing1, @walking2 = @tileset[@charaset_idx + 3..@charaset_idx + 5]
      when :right
        @walking1, @standing1, @walking2 = @tileset[@charaset_idx + 6..@charaset_idx + 8]
      when :down
        @walking1, @standing1, @walking2 = @tileset[@charaset_idx + 9..@charaset_idx + 11]
      end
    end
    @cur_image = @standing1
  end
  
  def update_walking_actor
    if Gosu.milliseconds / 175 % 4 == 0
      @cur_image = @standing1
    elsif Gosu.milliseconds / 175 % 4 == 1
      @cur_image = @walking1
    elsif Gosu.milliseconds / 175 % 4 == 2
      @cur_image = @standing1
    elsif Gosu.milliseconds / 175 % 4 == 3
      @cur_image = @walking2
    end
  end
  
  def move_to(path)
    x, y = path[0] * 32, path[1] * 32
    if @x < x
      @face_to = :right
      @x += @move_speed
      c_w_e = collide_with_events?
      if c_w_e && @path.length != 1
        @x -= @move_speed
        if !@game.scene.map.is_solid?(@x / 32, @y / 32 - 1)
          @path = @game.scene.map.bfs([@x/32, @y / 32-1], @path[-1], :right)
          @path.unshift([@x/32, @y/32-1])
        elsif !@game.scene.map.is_solid?(@x / 32, @y / 32 + 1)
          @path = @game.scene.map.bfs([@x/32, @y / 32+1], @path[-1], :right)
          @path.unshift([@x/32, @y/32+1])
        else
          @path = []
        end
        return
      elsif @path.length == 1 && c_w_e 
        @path = []
        return
      end
      if @game.scene.map.camera_x < @game.scene.map.width * 32 - @game.width && @x > @game.width / 2 && @x < @game.scene.map.width * 32 - @game.width / 2
        @game.scene.map.camera_x += @move_speed
        @game.mouse_x -= @move_speed
      end
    elsif @x > x
      @face_to = :left
      @x -= @move_speed
      c_w_e = collide_with_events?
      if c_w_e && @path.length != 1
        @x += @move_speed
        if !@game.scene.map.is_solid?(@x / 32, @y / 32 - 1)
          @path = @game.scene.map.bfs([@x/32, @y / 32-1], @path[-1], :left)
          @path.unshift([@x/32, @y/32-1])
        elsif !@game.scene.map.is_solid?(@x / 32, @y / 32 + 1)
          @path = @game.scene.map.bfs([@x/32, @y / 32+1], @path[-1], :left)
          @path.unshift([@x/32, @y/32+1])
        else
          @path = []
        end
        return
      elsif @path.length == 1 && c_w_e 
        @path = []
        return
      end
      if @game.scene.map.camera_x > 0 && @x >= @game.width / 2 && @x < @game.scene.map.width * 32 - @game.width / 2
        @game.scene.map.camera_x -= @move_speed
        @game.mouse_x += @move_speed
      end
    elsif @y < y
      @face_to = :down
      @y += @move_speed
      c_w_e = collide_with_events?
      if c_w_e && @path.length != 1
        @y -= @move_speed
        if !@game.scene.map.is_solid?(@x / 32 - 1, @y / 32)
          @path = @game.scene.map.bfs([@x/32-1, @y / 32], @path[-1], :down)
          @path.unshift([@x/32-1, @y/32])
        elsif !@game.scene.map.is_solid?(@x / 32 + 1, @y / 32)
          @path = @game.scene.map.bfs([@x/32+1, @y / 32], @path[-1], :down)
          @path.unshift([@x/32+1, @y/32])
        else
          @path = []
        end
        return
      elsif @path.length == 1 && c_w_e
        @path = []
        return
      end
      if @game.scene.map.camera_y < @game.scene.map.height * 32 - @game.height && @y > @game.height / 2 && @y < @game.scene.map.height * 32 - @game.height / 2
        @game.scene.map.camera_y += @move_speed
        @game.mouse_y -= @move_speed
      end
    elsif @y > y
      @face_to = :up
      @y -= @move_speed
      c_w_e = collide_with_events?
      if c_w_e && @path.length != 1
        @y += @move_speed
        if !@game.scene.map.is_solid?(@x / 32 - 1, @y / 32)
          @path = @game.scene.map.bfs([@x/32-1, @y / 32], @path[-1])
          @path.unshift([@x/32-1, @y/32])
        elsif !@game.scene.map.is_solid?(@x / 32 + 1, @y / 32)
          @path = @game.scene.map.bfs([@x/32+1, @y / 32], @path[-1])
          @path.unshift([@x/32+1, @y/32])
        else
          @path = []
        end
        return
      elsif @path.length == 1 && c_w_e
        @path = []
        return
      end
      if @game.scene.map.camera_y > 0 && @y > @game.height / 2 - 32 && @y < @game.scene.map.height * 32 - @game.height / 2
        @game.scene.map.camera_y -= @move_speed
        @game.mouse_y += @move_speed
      end
    end
  end

  def move_in_path
    if @path.length != 0
      update_walking_actor
      move_to(@path[0])
      if @path.length != 0 && @x == @path[0][0] * 32 && @y == @path[0][1] * 32
        @path.shift
        if @ending_face_to != nil && @path.length == 0
          @face_to = @ending_face_to
        end
      end
    end
  end

  def collide_with_events?
    @game.scene.map.events.each do |event|
      next if !event.active2 || !event.self_switch || event.passable
      case @face_to
      when :left
        return true if @x < event.x + 32 && @x > event.x && @y < event.y + 32 && @y > event.y - 32
      when :right
        return true if @x + 32 > event.x && @x < event.x && @y < event.y + 32 && @y > event.y - 32
      when :up
        return true if @x > event.x - 32 && @x < event.x + 32 && @y < event.y + 32 && @y > event.y
      when :down
        return true if @x > event.x - 32 && @x < event.x + 32 && @y + 32 > event.y && @y < event.y
      end
    end
    return false
  end
end
class Event
  attr_accessor :x, :y, :z, :name, :passable, :face_to, :move_speed, :move_type, :selectable, :cmds, :cmd_idx, :active, :active2, :path, :exe_type, :self_switch, :event_type, :status
  def initialize(game, event_id)
    @game = game
    attr_filename = 'Events\\' + event_id + '.txt'
    cmd_filename = 'Events\\' + event_id + '_cmds.txt'
    attrs = File.readlines(attr_filename, {encoding:'utf-8'}).map{ |line| line = line.chomp }
    @cmds = File.readlines(cmd_filename, {encoding:'utf-8'}).map{ |line| line = line.chomp }
    @cmd_idx = 2
    @x, @y = attrs[1].to_i * 32, attrs[2].to_i * 32
    @z = GameMain::EVENTS_Z
    @name = attrs[3]
    @passable = (attrs[4] == 'true') ? true : false
    charaset_filename = attrs[7].chomp 
    @tileset = charaset_filename != '' ? (Gosu::Image.load_tiles('Graphics/Charasets/' + charaset_filename + '.png', 32, 32)) : nil
    @charaset_idx = attrs[5].to_i
    @face_to = attrs[6].to_sym
    @move_speed = attrs[8].to_f
    @move_type = attrs[9].to_sym
    @active = false
    @active2 = eval(@cmds[0])
    @path = []
    @exe_type = attrs[10].to_sym
    @event_type = attrs[11].to_sym
    @self_switch = true
    @status = :ahead
  end

  def draw
    @cur_image.draw(@x - @game.scene.map.camera_x, @y - @game.scene.map.camera_y, @z) if @cur_image
  end

  def update(actor, mouse_x, mouse_y)
    @active2 = eval(@cmds[1])
    event_pose
    if !mouse_on?(mouse_x, mouse_y) && @active2 && @self_switch
      case @move_type
      when :random
        random_move(actor)
      when :move_to_actor
        actor = @game.scene.actor
        if (@x / 32 - actor.x / 32).abs > 5 || (@y / 32 - actor.y / 32).abs > 5
          random_move(actor)
        else
          move_to_actor(actor)
        end
      when :move_in_path
        if @path.length != 0
          move_to(actor, @path[0])
          @path.shift if @x == @path[0][0] * 32 && @y == @path[0][1] * 32
        else
          @status = :ahead
        end
      when :stay
      end
    else
    end
  end

  def choose_event(mouse_x, mouse_y)
    return self if  @active2 && @self_switch && mouse_on?(mouse_x, mouse_y) && actor_around?
    return nil
  end

  def change_path
    direct = [[((@x - 32) / 32).floor, (@y / 32).floor], [((@x + 32) / 32).floor, (@y / 32).floor], [(@x / 32).floor, ((@y - 32) / 32).floor], [(@x / 32).floor, ((@y + 32) / 32).floor]]
    num = rand(4)
    if !@game.scene.map.is_solid?(direct[num][0], direct[num][1])
      @path = [direct[num]]
    end
  end

  def event_pose
    if @tileset != nil
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
  end

  def update_walking_event
    if @tileset != nil
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
  end

  def move_to(actor, path)
    x, y = path[0] * 32, path[1] * 32
    if @x < x
      @face_to = :right
      @x += @move_speed
      if collide_with_events? || collide_with_actor?(actor)
        @x -= @move_speed 
        change_path if @move_type == :random
      end
    elsif @x > x
      @face_to = :left
      @x -= @move_speed
      if collide_with_events? || collide_with_actor?(actor)
        @x += @move_speed
        change_path if @move_type == :random
      end
    elsif @y < y
      @face_to = :down
      @y += @move_speed
      if collide_with_events? || collide_with_actor?(actor)
        @y -= @move_speed 
        change_path if @move_type == :random
      end
    elsif @y > y
      @face_to = :up
      @y -= @move_speed
      if collide_with_events? || collide_with_actor?(actor)
        @y += @move_speed 
        change_path if @move_type == :random
      end
    end
  end

  def collide_with_events?
    @game.scene.map.events.each do |event|
      next if event == self || !event.active2
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

  def collide_with_actor?(actor)
    case @face_to
    when :left
      return true if @x < actor.x + 32 && @x > actor.x && @y < actor.y + 32 && @y > actor.y - 32
    when :right
      return true if @x + 32 > actor.x && @x < actor.x && @y < actor.y + 32 && @y > actor.y - 32
    when :up
      return true if @x > actor.x - 32 && @x < actor.x + 32 && @y < actor.y + 32 && @y > actor.y
    when :down
      return true if @x > actor.x - 32 && @x < actor.x + 32 && @y + 32 > actor.y && @y < actor.y
    end
    return false
  end

  def mouse_on?(mouse_x, mouse_y)
    if !@passable && !@game.event_executing && @x / 32 == ((mouse_x + @game.scene.map.camera_x) / 32).floor && @y / 32 == ((mouse_y + @game.scene.map.camera_y) / 32).floor
      return true
    end
    return false
  end

  def actor_around?
    actor = @game.scene.actor
    return true if actor.x >= @x - 32 && actor.x <= @x + 32 && actor.y >= @y - 32 && actor.y <= @y + 32
    return false
  end

  def face_to_actor(actor)
    if actor.x > @x
      actor.face_to = :left
      @face_to = :right
    elsif actor.x < @x
      actor.face_to = :right
      @face_to = :left
    elsif actor.y > @y
      actor.face_to = :up
      @face_to = :down
    elsif actor.y < @y
      actor.face_to = :down
      @face_to = :up
    end
  end

  def is_face_to_actor?(actor)
    if @x < actor.x && @y == actor.y && @face_to == :right
      return true
    elsif @x > actor.x && @y == actor.y && @face_to == :left
      return true
    elsif @y < actor.y && @x == actor.x && @face_to == :down
      return true
    elsif @y > actor.y && @x == actor.x && @face_to == :up
      return true
    else
      return false
    end
  end


  def random_move(actor)
    if @path.length != 0
      update_walking_event
      move_to(actor, @path[0])
      if @x == @path[0][0] * 32 && @y == @path[0][1] * 32
        @path.shift
      end
    elsif @path.length == 0
      change_path
    end
  end

  def move_to_actor(actor)
    if @path.length != 0
      update_walking_event
      move_to(actor, @path[0])
      if @path.length != 0 && @x == @path[0][0] * 32 && @y == @path[0][1] * 32
        @path.shift
      end
    elsif @path.length == 0
      paths = []
      paths << [@x / 32 + 1, @y / 32] if @x < actor.x && !@game.scene.map.is_solid?(@x / 32 + 1, @y / 32)
      paths << [@x / 32 - 1, @y / 32] if @x > actor.x && !@game.scene.map.is_solid?(@x / 32 - 1, @y / 32)
      paths << [@x / 32, @y / 32 + 1] if @y < actor.y && !@game.scene.map.is_solid?(@x / 32, @y / 32 + 1)
      paths << [@x / 32, @y / 32 - 1] if @y > actor.y && !@game.scene.map.is_solid?(@x / 32, @y / 32 - 1)
      @path = paths.length != 0 ? [paths[rand(paths.length)]] : []
    end
  end

end
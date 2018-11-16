class GameMain < Gosu::Window
  attr_accessor :mouse, :scene, :fading_type, :curtain, :switches, :variables, :game_date, :event_executing, :selection
  MOUSE_Z = 100
  WINDOW_Z = 50
  MAP_Z = 0
  EVENTS_Z = 10
  def initialize
    super 640, 480, false
    self.caption = 'Test'
		@switches = [false] * 999
    @variables = {'game_process' => 0}
    @game_date = GameDate.new
    @mouse = Mouse.new(self)
    @scene = SceneMain.new(self, @game_date)
    @curtain = 0
    @event_executing = false
    @ticK = 0
    @selection = 0
    # @window = WindowSelections.new(self, ['救段誉', '无动于衷'])
  end
  
  def draw
    @mouse.draw(mouse_x, mouse_y)
    @scene.draw
    draw_curtain(@curtain)
    # @window.draw
  end

  def update
		@curtain -= 5 if @curtain > 0
    @mouse.update(mouse_x, mouse_y)
    @scene.update(mouse_x, mouse_y)
    @game_date.update if @scene.map.active
    # @window.update(mouse_x, mouse_y)
  end

  def button_down(id)
    @scene.button_down(mouse_x, mouse_y, id) if @curtain == 0
    # @window.button_down(id)
  end

  def select_event(num)
    return @scene.map.events[num]
  end

  def dialog(texts)
    @scene.actor.path = [] if @scene.actor.path.length != 0
    @scene.window_dialog.active = true
    @scene.map.active = false
    @scene.window_dialog.texts = texts
  end

  def show_selections(options)
    window = @scene.window_selections
    window.options = options
    @scene.map.active = false
    window.active = true
  end

  def move_to(event, move_speed, path, status=:ahead)
    event.move_type = :move_in_path
    event.status = status
    event.move_speed = move_speed
    event.path = path
  end

  def waiting_for_events_moving
    @scene.map.event_moving = true
  end

  def wait_for(event, sec)
    now_tick = Gosu::milliseconds
    if @ticK == 0
      @ticK = now_tick
      event.cmd_idx -= 1
      event.cmd_idx = event.cmd_idx.length - 1 if event.cmd_idx == 0
    elsif now_tick < @ticK + sec * 1000
      event.cmd_idx -= 1
      event.cmd_idx = event.cmd_idx.length - 1 if event.cmd_idx == 0
    else
      @ticK = 0
    end
  end

  def teleport(map, map_x, map_y, face_to)
    @scene.map = map
    @scene.actor.x = map_x * 32
    @scene.actor.y = map_y * 32
    @scene.actor.face_to = face_to
    set_camera(map)
  end

  def set_camera(map)
    map.camera_x = @scene.actor.x - self.width / 2
    if map.camera_x < 0
      map.camera_x = 0
    elsif map.camera_x > map.width * 32 - self.width
      map.camera_x = map.width * 32 - self.width
    end
    map.camera_y = @scene.actor.y - self.height / 2
    if map.camera_y < 0
      map.camera_y = 0
    elsif map.camera_y > map.height * 32 - self.height
      map.camera_y = map.height * 32 - self.height
    end
  end

  def draw_curtain(curtain)
    color = Gosu::Color.new(curtain, 0, 0, 0)
    draw_quad(0, 0, color, width, 0, color, width, height, color, 0, height, color, 200)
	end
	
	def close_curtain
		@curtain = 300
	end

  def open_switch(num)
    @switches[num] = true
  end

  def close_switch(num)
    @switches[num] = false
  end

  def set_variable(name, val)
    @variables[name] = val
  end
end
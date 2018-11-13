class GameMain < Gosu::Window
  attr_accessor :mouse, :scene, :fading_type, :maku, :switches, :variables
  MOUSE_Z = 100
  WINDOW_Z = 50
  MAP_Z = 0
  EVENTS_Z = 10
  def initialize
    super 640, 480, false
    self.caption = 'Test'
    @switches = [false] * 999
    @variables = {'game_process' => 0}
    @mouse = Mouse.new(self)
    @scene = SceneMain.new(self)
    @maku = 0
    @fading_type = :IN
  end
  
  def draw
    @mouse.draw(mouse_x, mouse_y)
    @scene.draw
    draw_maku(@maku)
  end

  def update
    if @fading_type == :OUT
      @maku += 5 if @maku < 300
    elsif @fading_type == :IN
      @maku -= 5 if @maku > 0
    end
    @mouse.update(mouse_x, mouse_y)
    @scene.update(mouse_x, mouse_y)
  end

  def button_down(id)
    @scene.button_down(mouse_x, mouse_y, id) if @maku == 0
  end

  def dialog(texts)
    @scene.actor.path = [] if @scene.actor.path.length != 0
    @scene.window_dialog.active = true
    @scene.map.active = false
    @scene.window_dialog.texts = texts
  end

  def teleport(map, map_x, map_y, face_to)
    @scene.map = map
    @scene.actor.x = map_x * 32
    @scene.actor.y = map_y * 32
    @scene.actor.face_to = face_to
    set_camera(map)
    @fading_type = :IN
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

  def draw_maku(maku)
    color = Gosu::Color.new(maku, 0, 0, 0)
    draw_quad(0, 0, color, width, 0, color, width, height, color, 0, height, color, 200)
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
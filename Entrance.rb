require 'gosu'
require 'thread'
require_relative 'Mouse'
require_relative 'WindowBase'
require_relative 'WindowDialog'
require_relative 'WindowSelectable'
require_relative 'WindowCommand'
require_relative 'WindowWeapon'
require_relative 'WindowStatus'
require_relative 'Tileset'
require_relative 'Map'
require_relative 'Actor'
require_relative 'Event'
require_relative 'SceneMain'
require_relative 'Main'

game = GameMain.new
game.show
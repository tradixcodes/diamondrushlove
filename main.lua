local Map = require("map")
local Player = require("player")
local Camera = require("camera")
local Stones = require("stones")
local Bush = require("bush")
local Diagnostics = require("diagnostics")

TILE = 32

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	GAMEFONT = love.graphics.newFont("/fonts/Satoshi-Variable.ttf", 10, "normal", 2)
	love.graphics.setFont(GAMEFONT)

	Map.load("ankgor_watt_intro_level")
	Stones.init(Map.getGrid(), Map.getStones())
	Bush.init(Map.getGrid(), Map.getBushes())
	Player.init(Map)
	Camera.init()
end

function love.update(dt)
	Player.update(dt)
	Stones.update(dt)
	Bush.update(dt)
	local x, y = Player.getPosition()
	local mapWidth, mapHeight = Map.getSize()
	Camera.follow(x, y, mapWidth, mapHeight)
end

function love.draw()
	Camera.attach()
	Map.draw()
	Bush.draw() -- under stones
	Stones.draw()
	Player.draw()
	Camera.detach()
	Diagnostics.draw()
end

function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
	end
	Player.handleInput(key)
end

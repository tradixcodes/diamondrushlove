local Canvas = require("canvas")
local Map = require("map")
local UI = require("ui")

TILE = 32
-- main file
function love.load()
	-- creates the canvas with the fixed resolution
	Canvas.load()
	UI.load()
	-- load grid
	Map.initializeGrid()
end

function love.update(dt)
	if UI.isInGame() then
		Map.update(dt)
	end
	UI.update(dt)
end

function love.draw()
	-- you tell LÖVE to stop drawing to the screen and start drawing to your Canvas using Canvas.set()
	Canvas.set()
	if UI.isInGame() then
		-- game drawing
		Map.drawGrid()
	end
	UI.draw()
	-- Detach the canvas (points drawing back to the main window)
	Canvas.unset()
	-- Draw the canvas scaled up to the actual window size
	UI.drawCanvas(Canvas.buffer, Canvas.VIRTUAL_W, Canvas.VIRTUAL_H)
end

function love.keypressed(key)
	UI.keypressed(key)
end

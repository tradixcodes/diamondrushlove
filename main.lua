local Canvas = require("canvas")
local Map = require("map")
local UI = require("ui")
local DevTools = require("devtools")
local Player = require("player")

TILE = 32
love.graphics.setDefaultFilter("nearest", "nearest")
-- main file
function love.load()
	defaultFont = love.graphics.newFont("fonts/Satoshi-Variable.ttf", 16, "normal", 2)
	-- creates the canvas with the fixed resolution
	Canvas.load()
	UI.load()
	-- load grid
	Map.initializeGrid()
	Map.loadLevel("levels/ankgor_watt_intro_level.lua")

	local startCol, startRow = Map.getPlayerStart()
	Player.load(startCol, startRow)
end

function love.update(dt)
	if UI.isInGame() then
		Map.update(dt)
		Player.update(dt)
	end
	UI.update(dt)
end

function love.draw()
	-- you tell LÖVE to stop drawing to the screen and start drawing to your Canvas using Canvas.set()
	Canvas.set()
	if UI.isInGame() then
		Map.draw()
		Map.drawGrid()
		Player.draw()
	end
	UI.draw() -- sets the pixel font internally
	love.graphics.setFont(defaultFont) -- restore after UI is done
	-- Detach the canvas (points drawing back to the main window)
	Canvas.unset()
	-- Draw the canvas scaled up to the actual window size
	UI.drawCanvas(Canvas.buffer, Canvas.VIRTUAL_W, Canvas.VIRTUAL_H)

	-- dev overlays draw on top of everything including the pause screen
	if UI.isInGame() then
		if DevTools.showFPS then
			love.graphics.print("FPS: " .. love.timer.getFPS(), 8, 8)
		end

		if DevTools.showCoords then
			love.graphics.print("COL: " .. Player.col .. " ROW: " .. Player.row, 8, 28)
		end
	end
end

function love.keypressed(key)
	UI.keypressed(key)
	if UI.isInGame() then
		-- Player.handleInput(key)
	end
end

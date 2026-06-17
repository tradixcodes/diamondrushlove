local Canvas = {}

-- sets a virtual canvas of 384 by 288 px (perfect for 32 pixel borders)
local VIRTUAL_W, VIRTUAL_H = 384, 288

Canvas.VIRTUAL_W = VIRTUAL_W
Canvas.VIRTUAL_H = VIRTUAL_H

function Canvas.load()
	Canvas.buffer = love.graphics.newCanvas(VIRTUAL_W, VIRTUAL_H)
	Canvas.buffer:setFilter("nearest", "nearest")
end

function Canvas.set()
	-- sets the created canvas at canvas.load
	love.graphics.setCanvas(Canvas.buffer)
	-- Clear the canvas from the last frame
	love.graphics.clear()
end

function Canvas.unset()
	-- Detach the canvas (points drawing back to the main window)
	love.graphics.setCanvas()
end

return Canvas

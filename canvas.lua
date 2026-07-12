local Canvas = {}

Canvas.VIRTUAL_W = 384
Canvas.VIRTUAL_H = 288

function Canvas.load()
	Canvas.buffer = love.graphics.newCanvas(Canvas.VIRTUAL_W, Canvas.VIRTUAL_H)
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

function Canvas.getSafeArea(winW, winH)
	local scale = math.max(winW / Canvas.VIRTUAL_W, winH / Canvas.VIRTUAL_H) -- fill mode scale
	local ox = (winW - Canvas.VIRTUAL_W * scale) / 2
	local oy = (winH - Canvas.VIRTUAL_H * scale) / 2

	-- convert screen crop back into canvas coordinates
	local safeLeft = math.max(0, -ox / scale)
	local safeTop = math.max(0, -oy / scale)
	local safeRight = math.min(Canvas.VIRTUAL_W, Canvas.VIRTUAL_W + ox / scale)
	local safeBottom = math.min(Canvas.VIRTUAL_H, Canvas.VIRTUAL_H + oy / scale)

	return {
		left = safeLeft,
		top = safeTop,
		right = safeRight,
		bottom = safeBottom,
		width = safeRight - safeLeft,
		height = safeBottom - safeTop,
		centerX = safeLeft + (safeRight - safeLeft) / 2,
		centerY = safeTop + (safeBottom - safeTop) / 2,
	}
end

return Canvas

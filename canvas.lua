local Canvas = {}

local VIRTUAL_W, VIRTUAL_H = 320, 240

function Canvas.load()
    Canvas.buffer = love.graphics.newCanvas(VIRTUAL_W, VIRTUAL_H)
    Canvas.buffer:setFilter("nearest", "nearest")
end

function Canvas.set()
    love.graphics.setCanvas(Canvas.buffer)
    love.graphics.clear()
end

function Canvas.unset()
    love.graphics.setCanvas()
end

function Canvas.draw()
    local winW, winH = love.graphics.getDimensions()
    local scale = math.min(winW / VIRTUAL_W, winH / VIRTUAL_H)
    local offsetX = (winW - VIRTUAL_W * scale) / 2
    local offsetY = (winH - VIRTUAL_H * scale) / 2

    love.graphics.draw(Canvas.buffer, offsetX, offsetY, 0, scale, scale)
end

return Canvas

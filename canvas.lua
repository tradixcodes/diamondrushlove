local UI = require("ui")

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
    UI.drawCanvas(Canvas.buffer, VIRTUAL_W, VIRTUAL_H)
end

return Canvas

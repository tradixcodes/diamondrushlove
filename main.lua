local Canvas = require("canvas")
local Map = require("maps")
local UI = require("ui")

TILE = 32
-- main file
function love.load()
    Canvas.load()
    -- 1. Create the world(create a grid)
    Map.initializeGrid()
end

function love.update(dt) end

function love.draw()
    Canvas.set()
    -- game drawing
    Map.drawGrid()
    Canvas.unset()
    Canvas.draw()
end

function love.keypressed(key)
    if key == "tab" then UI.cycleView() end
end

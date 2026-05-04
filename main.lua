local Map = require("map")
local Player = require("player")
local Camera = require("camera")
local Stones = require("stones")

TILE = 32

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    GAMEFONT = love.graphics.newFont("/fonts/Satoshi-Variable.ttf", 15, "normal", 2)
    love.graphics.setFont(GAMEFONT)

    Map.load("ankgor_watt_intro_level")
    Stones.init(Map.getGrid(), Map.getStones()) -- needs getGrid too
    Player.init(Map)
    Camera.init()
end

function love.update(dt)
    Player.update(dt)
    Stones.update(dt)
    local x, y = Player.getPosition()
    local mapWidth, mapHeight = Map.getSize()
    Camera.follow(x, y, mapWidth, mapHeight)
end

function love.draw()
    Camera.attach()
    Map.draw()
    Stones.draw()
    Player.draw()
    Camera.detach()
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    Player.handleInput(key)
end

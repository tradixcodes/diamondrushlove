local TILE    = 32
local EMPTY   = 0
local BUSH    = 4

local anim8   = require("library/anim8/anim8")

local grid    = nil
local bushes  = {}

local sprites = {}

local function newAnim()
    return anim8.newAnimation(
        anim8.newGrid(44, 35,
            sprites.bush:getWidth(),
            sprites.bush:getHeight())("1-8", 1),
        0.25
    )
end

local function init(gridRef, bushList)
    grid                 = gridRef
    bushes               = {}

    sprites.bush         = love.graphics.newImage("sprites_png/bush_animation_tileset.png")

    sprites.bushIdleQuad = love.graphics.newQuad(
        0, 0, 44, 35,
        sprites.bush:getWidth(), sprites.bush:getHeight()
    )

    for _, b in ipairs(bushList) do
        table.insert(bushes, {
            col   = b.col,
            row   = b.row,
            dying = false,
            anim  = newAnim(),
        })
    end
end

local function clear(col, row)
    for _, b in ipairs(bushes) do
        if b.col == col and b.row == row and not b.dying then
            b.dying = true
            b.anim:gotoFrame(1)
            b.anim:pauseAtEnd() -- play once, stop on last frame, then cleaned up
            grid[row][col] = EMPTY
            return
        end
    end
end

local function update(dt)
    local alive = {}
    for _, b in ipairs(bushes) do
        if b.dying then
            b.anim:update(dt)
            -- anim8 sets status to "paused" when pauseAtEnd animation finishes
            if b.anim.status == "playing" then
                table.insert(alive, b)
            end
            -- status == "paused" means it finished its one run, drop it
        else
            table.insert(alive, b)
        end
    end
    bushes = alive
end

local function draw()
    for _, b in ipairs(bushes) do
        if b.dying then
            b.anim:draw(sprites.bush, b.col * TILE, b.row * TILE)
        else
            love.graphics.draw(sprites.bush, sprites.bushIdleQuad,
                b.col * TILE, b.row * TILE)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return { init = init, update = update, draw = draw, clear = clear }

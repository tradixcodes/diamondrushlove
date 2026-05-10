local TILE    = 32
local EMPTY   = 0
local BUSH    = 4

local anim8   = require("library/anim8/anim8")

local grid    = nil
local bushes  = {}

local sprites = {}

-- ── private ──────────────────────────────────────────────────────────────────
-- each bush gets its own animation instance so they play independently
local function newAnim()
    return anim8.newAnimation(
        anim8.newGrid(44, 35,
            sprites.bush:getWidth(),
            sprites.bush:getHeight())("1-8", 1),
        0.25
    )
end

-- ── public ───────────────────────────────────────────────────────────────────
local function init(gridRef, bushList)
    grid                 = gridRef
    bushes               = {}

    sprites.bush         = love.graphics.newImage("sprites_png/bush_animation_tileset.png")

    -- static quad for idle state, same reason as stones
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

-- called by player.lua after the player steps into a cell.
-- safe to call on any cell -- does nothing if there is no bush there.
local function clear(col, row)
    for _, b in ipairs(bushes) do
        if b.col == col and b.row == row and not b.dying then
            b.dying = true
            b.anim:gotoFrame(1)
            grid[row][col] = EMPTY -- stone above can now fall next tick
            return
        end
    end
end

local function update(dt)
    local alive = {}
    for _, b in ipairs(bushes) do
        if b.dying then
            b.anim:update(dt)
            -- keep it only while the animation is still playing
            if b.anim.status == "playing" then
                table.insert(alive, b)
            end
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

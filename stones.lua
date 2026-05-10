local TILE            = 32

local EMPTY           = 0
local WALL            = 1
local STONE           = 2
local DIAMOND         = 3

local anim8           = require("library/anim8/anim8")

local grid            = nil
local stones          = {}
local tickRate        = 0.12
local tickTimer       = 0

local renderPositions = {}

local sprites         = {}
local animations      = {}

local function isRound(col, row)
    local cell = grid[row] and grid[row][col]
    return cell == STONE or cell == DIAMOND
end

local function isEmpty(col, row)
    if not grid[row] then return false end
    return grid[row][col] == EMPTY
end

local function setRenderTarget(i, col, row)
    local r   = renderPositions[i]
    r.startX  = r.renderX
    r.startY  = r.renderY
    r.targetX = col * TILE
    r.targetY = row * TILE
end

local function updateStone(i)
    local s = stones[i]
    local below = s.row + 1

    if isEmpty(s.col, below) then
        grid[s.row][s.col] = EMPTY
        s.row              = below
        grid[s.row][s.col] = STONE
        s.falling          = true
        s.teeterDir        = nil
        s.teeterTimer      = 0
        setRenderTarget(i, s.col, s.row)
        return
    end

    if isRound(s.col, below) then
        local leftFree  = isEmpty(s.col - 1, s.row) and isEmpty(s.col - 1, below)
        local rightFree = isEmpty(s.col + 1, s.row) and isEmpty(s.col + 1, below)

        if leftFree or rightFree then
            local dir = leftFree and "left" or "right"

            if s.teeterDir == dir then
                s.teeterTimer = s.teeterTimer + 1
                if s.teeterTimer >= s.teeterDuration then
                    local dc           = dir == "left" and -1 or 1
                    grid[s.row][s.col] = EMPTY
                    s.col              = s.col + dc
                    grid[s.row][s.col] = STONE
                    s.teeterDir        = nil
                    s.teeterTimer      = 0
                    s.falling          = false
                    setRenderTarget(i, s.col, s.row)
                end
            else
                s.teeterDir   = dir
                s.teeterTimer = 1
            end
            return
        end
    end

    s.falling     = false
    s.teeterDir   = nil
    s.teeterTimer = 0
end

local function updateRender(dt)
    for i in ipairs(stones) do
        local r = renderPositions[i]
        r.lerpTimer = math.min(r.lerpTimer + dt, tickRate)
        local t = r.lerpTimer / tickRate
        t = t * t * (3 - 2 * t)
        r.renderX = r.startX + (r.targetX - r.startX) * t
        r.renderY = r.startY + (r.targetY - r.startY) * t
    end
end

local function init(gridRef, stoneList)
    grid                  = gridRef
    stones                = {}
    renderPositions       = {}

    sprites.stone         = love.graphics.newImage("sprites_png/aw_stones_tileset.png")

    local g               = anim8.newGrid(32, 32,
        sprites.stone:getWidth(), sprites.stone:getHeight())

    animations.roll       = anim8.newAnimation(g("1-3", 1, "1-3", 2, "1-2", 3), 0.1)

    sprites.stoneIdleQuad = love.graphics.newQuad(
        0, 0, 32, 32,
        sprites.stone:getWidth(), sprites.stone:getHeight()
    )

    for _, s in ipairs(stoneList) do
        table.insert(stones, {
            col            = s.col,
            row            = s.row,
            falling        = false,
            teeterDir      = nil,
            teeterTimer    = 0,
            teeterDuration = 3,
        })
        local rx, ry = s.col * TILE, s.row * TILE
        table.insert(renderPositions, {
            renderX = rx,
            renderY = ry,
            startX = rx,
            startY = ry,
            targetX = rx,
            targetY = ry,
            lerpTimer = tickRate,
        })
    end
end

-- called by player.lua on a horizontal move into a stone cell.
-- returns true and moves the stone if the cell beyond it is empty,
-- returns false if the stone is blocked and the player should not move.
local function tryPush(col, row, dc)
    for i, s in ipairs(stones) do
        if s.col == col and s.row == row then
            local destCol = col + dc
            if isEmpty(destCol, s.row) then
                grid[s.row][s.col] = EMPTY
                s.col = destCol
                grid[s.row][s.col] = STONE
                s.falling = false
                -- reset lerp so the stone visually slides from where it was
                renderPositions[i].lerpTimer = 0
                setRenderTarget(i, s.col, s.row)
                return true
            else
                return false
            end
        end
    end
    return false
end

local function update(dt)
    updateRender(dt)

    local anyFalling = false
    for _, s in ipairs(stones) do
        if s.falling then
            anyFalling = true; break
        end
    end
    if anyFalling then
        animations.roll:update(dt)
    end

    tickTimer = tickTimer + dt
    if tickTimer >= tickRate then
        tickTimer = tickTimer - tickRate
        for i = 1, #stones do
            updateStone(i)
        end
        for _, r in ipairs(renderPositions) do
            r.startX    = r.renderX
            r.startY    = r.renderY
            r.lerpTimer = 0
        end
    end
end

local function draw()
    for i, s in ipairs(stones) do
        local r = renderPositions[i]
        if s.falling then
            animations.roll:draw(sprites.stone, r.renderX, r.renderY)
        else
            love.graphics.draw(sprites.stone, sprites.stoneIdleQuad,
                r.renderX, r.renderY)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return { init = init, update = update, draw = draw, tryPush = tryPush }

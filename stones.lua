local TILE = 32

local EMPTY = 0
local WALL = 1
local STONE = 2
local DIAMOND = 3

local grid = nil
local stones = {}
local tickRate = 0.12
local tickTimer = 0

-- each stone's visual interpolation
local renderPositions = {} -- keyed by stone index

-- private: what cells can a stone slide off of
local function isRound(col, row)
    local cell = grid[row] and grid[row][col]
    return cell == STONE or cell == DIAMOND
end

local function isEmpty(col, row)
    if not grid[row] then return false end
    return grid[row][col] == EMPTY
end

-- private: core ruler per tick
local function updateStone(i)
    local s = stones[i]

    -- rule 1: fall straight down
    if isEmpty(s.col, s.row + 1) then
        grid[s.row][s.col] = EMPTY
        s.row = s.row + 1
        grid[s.row][s.col] = STONE
        s.falling = true
        s.teeterDir = nil
        s.teeterTimer = 0

        -- sync render start
        renderPositions[i].startX = renderPositions[i].renderX
        renderPositions[i].startY = renderPositions[i].renderY
        renderPositions[i].targetX = s.col * TILE
        renderPositions[i].targetY = s.row * TILE
        return
    end

    -- rule 2: blocked below, check if sitting on something round
    if isRound(s.col, s.row + 1) then
        local leftFree = isEmpty(s.col - 1, s.row) and isEmpty(s.col - 1, s.row + 1)
        local rightFree = isEmpty(s.col + 1, s.row) and isEmpty(s.col + 1, s.row + 1)

        -- decide teeter direction
        if leftFree or rightFree then
            local dir = nil
            if leftFree and rightFree then
                dir = "left"
            elseif leftFree then
                dir = "left"
            else
                dir = "right"
            end

            if s.teeterDir == dir then
                s.teeterTimer = s.teeterTimer + 1
                if s.teeterTimer >= s.teeterDuration then
                    -- actually slide now
                    local dc = dir == "left" and -1 or 1
                    grid[s.row][s.col] = EMPTY
                    s.col = s.col + dc
                    grid[s.row][s.col] = STONE
                    s.teeterDir = nil
                    s.teeterTimer = 0
                    s.falling = false

                    renderPositions[i].startX = renderPositions[i].renderX
                    renderPositions[i].startY = renderPositions[i].renderY
                    renderPositions[i].targetX = s.col * TILE
                    renderPositions[i].targetY = s.row * TILE
                end
            else
                -- new direction, start teeter
                s.teeterDir = dir
                s.teeterTimer = 1
            end
            return
        end
    end
    -- rule 4: idle
    s.falling = false
    s.teeterDir = nil
    s.teeterTimer = 0
end

-- private: update all visual render positions
local function updateRender(dt)
    for i, s in ipairs(stones) do
        local r = renderPositions[i]
        r.lerpTimer = math.min(r.lerpTimer + dt, tickRate)
        local t = r.lerpTimer / tickRate
        t = t * t * (3 - 2 * t)

        r.renderX = r.startX + (r.targetX - r.startX) * t
        r.renderY = r.startY + (r.targetY - r.startY) * t
    end
end

-- public
local function init(gridRef, stoneList)
    grid = gridRef
    stones = {}
    renderPositions = {}

    for _, s in ipairs(stoneList) do
        table.insert(stones, {
            col = s.col,
            row = s.row,
            falling = false,
            teeterDir = nil,
            teeterTimer = 0,
            teeterDuration = 3, --ticks before sliding, tweak for feel
        })
        local rx = s.col * TILE
        local ry = s.row * TILE
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

local function update(dt)
    updateRender(dt)

    tickTimer = tickTimer + dt
    if tickTimer >= tickRate then
        tickTimer = tickTimer - tickRate

        -- top to bottom so falling stones don't double update
        for i = 1, #stones do
            updateStone(i)
        end

        -- reset lerp timers after tick
        for i, r in ipairs(renderPositions) do
            r.startX = r.renderX
            r.startY = r.renderY
            r.lerpTimer = 0
        end
    end
end

local function draw()
    for i, s in ipairs(stones) do
        local r = renderPositions[i]
        love.graphics.setColor(0.6, 0.5, 0.4, 1)
        love.graphics.rectangle("fill", r.renderX, r.renderY, TILE, TILE)
    end
    love.graphics.setColor(1, 1, 1, 1)
end

return {
    init = init,
    update = update,
    draw = draw,
}

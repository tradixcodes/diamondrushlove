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

    -- rulw 2: blocked below, check if sitting on something round
    if isRound(s.col, s.row + 1) then
        local leftFree = isEmpty(s.col - 1, s.row) and isEmpty(s.col - 1)
    end
end

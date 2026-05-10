local sti            = require("library/Simple-Tiled-Implementation/sti")

local grid           = {}
local gameMap        = nil
local mapWidth       = 0
local mapHeight      = 0
local playerSpawnCol = 0
local playerSpawnRow = 0
local stoneList      = {}
local bushList       = {}

local function parseWallObjects(layer)
    for _, obj in ipairs(layer.objects) do
        local col  = math.floor(obj.x / TILE)
        local row  = math.floor(obj.y / TILE)
        local cols = math.floor(obj.width / TILE)
        local rows = math.floor(obj.height / TILE)
        for r = row, row + rows - 1 do
            for c = col, col + cols - 1 do
                if grid[r] then grid[r][c] = 1 end
            end
        end
    end
end

local function parseStoneObjects(layer)
    for _, obj in ipairs(layer.objects) do
        local col  = math.floor(obj.x / TILE)
        local row  = math.floor(obj.y / TILE)
        local cols = math.floor(obj.width / TILE)
        local rows = math.floor(obj.height / TILE)
        for r = row, row + rows - 1 do
            for c = col, col + cols - 1 do
                if grid[r] then
                    grid[r][c] = 2
                    table.insert(stoneList, { col = c, row = r })
                end
            end
        end
    end
end

local function parseBushObjects(layer)
    for _, obj in ipairs(layer.objects) do
        local col  = math.floor(obj.x / TILE)
        local row  = math.floor(obj.y / TILE)
        local cols = math.floor(obj.width / TILE)
        local rows = math.floor(obj.height / TILE)
        for r = row, row + rows - 1 do
            for c = col, col + cols - 1 do
                if grid[r] then
                    grid[r][c] = 4
                    table.insert(bushList, { col = c, row = r })
                end
            end
        end
    end
end

local function parsePlayerSpawn(layer)
    for _, obj in pairs(layer.objects) do
        playerSpawnCol = math.floor(obj.x / TILE)
        playerSpawnRow = math.floor(obj.y / TILE)
    end
end

local function drawGrid()
    for row = 0, mapHeight - 1 do
        for col = 0, mapWidth - 1 do
            local x    = col * TILE
            local y    = row * TILE
            local cell = grid[row][col]
            if cell == 1 then
                love.graphics.setColor(1, 0, 0, 0.3)
                love.graphics.rectangle("fill", x, y, TILE, TILE)
            end
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.rectangle("line", x, y, TILE, TILE)
            love.graphics.setColor(1, 1, 1, 0.4)
            love.graphics.print(col .. "," .. row, x + 2, y + 2)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- walls and stones both block movement by default
local function isSolid(col, row)
    if row < 0 or col < 0 or row >= mapHeight or col >= mapWidth then
        return true
    end
    local cell = grid[row][col]
    return cell == 1 or cell == 2
end

-- lets other modules read a raw cell value without touching the grid directly
local function cellAt(col, row)
    if row < 0 or col < 0 or row >= mapHeight or col >= mapWidth then
        return -1
    end
    return grid[row][col]
end

local function load(mapName)
    gameMap   = sti("levels/" .. mapName .. ".lua")
    mapWidth  = gameMap.width
    mapHeight = gameMap.height

    for r = 0, mapHeight - 1 do
        grid[r] = {}
        for c = 0, mapWidth - 1 do
            grid[r][c] = 0
        end
    end

    parseWallObjects(gameMap.layers["walls_obj"])
    parseStoneObjects(gameMap.layers["stones_obj"])
    parseBushObjects(gameMap.layers["bushes_obj"])
    parsePlayerSpawn(gameMap.layers["player_obj"])
end

local function draw()
    gameMap:drawLayer(gameMap.layers["background"])
    gameMap:drawLayer(gameMap.layers["walls"])
    drawGrid()
end

local function getSize() return mapWidth, mapHeight end
local function getSpawn() return playerSpawnCol, playerSpawnRow end
local function getStones() return stoneList end
local function getBushes() return bushList end
local function getGrid() return grid end

return {
    load      = load,
    draw      = draw,
    isSolid   = isSolid,
    cellAt    = cellAt, -- new
    getSize   = getSize,
    getSpawn  = getSpawn,
    getStones = getStones,
    getBushes = getBushes,
    getGrid   = getGrid,
}

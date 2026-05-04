local sti = require("library/Simple-Tiled-Implementation/sti")

-- private: nobody outside needs these raw
local grid = {}
local gameMap = nil
local mapWidth = 0
local mapHeight = 0
local playerSpawnCol = 0
local playerSpawnRow = 0

local stoneList = {}
--private helper,only used inside this file
local function parseWallObjects(layer)
    for _, obj in ipairs(layer.objects) do
        local col = math.floor(obj.x / TILE)
        local row = math.floor(obj.y / TILE)
        local cols = math.floor(obj.width / TILE)
        local rows = math.floor(obj.height / TILE)
        for r = row, row + rows - 1 do
            for c = col, col + cols - 1 do
                if grid[r] then
                    grid[r][c] = 1 -- 1 for wall
                end
            end
        end
    end
end

local function parseStoneObjects(layer)
    for _, obj in ipairs(layer.objects) do
        local col = math.floor(obj.x / TILE)
        local row = math.floor(obj.y / TILE)
        local cols = math.floor(obj.width / TILE)
        local rows = math.floor(obj.height / TILE)
        for r = row, row + rows - 1 do
            for c = col, col + cols - 1 do
                if grid[r] then
                    grid[r][c] = 2 -- 2 for stone
                    table.insert(stoneList, { col = c, row = r })
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
            local x = col * TILE
            local y = row * TILE
            local cell = grid[row][col]

            if cell == 1 then
                love.graphics.setColor(1, 0, 0, 0.3)
                love.graphics.rectangle("fill", x, y, TILE, TILE)
            end

            --grid lines
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.rectangle("line", x, y, TILE, TILE)

            --cell coordinates
            love.graphics.setColor(1, 1, 1, 0.4)
            love.graphics.print(col .. "," .. row, x + 2, y + 2)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

-- public: main.lua calls this
local function isSolid(col, row)
    if row < 0 or col < 0 or row >= mapHeight or col >= mapWidth then
        return true
    end
    return grid[row][col] == 1
end

local function load(mapName)
    gameMap = sti("levels/" .. mapName .. ".lua")
    mapWidth = gameMap.width
    mapHeight = gameMap.height

    for r = 0, mapHeight - 1 do
        grid[r] = {}
        for c = 0, mapWidth - 1 do
            grid[r][c] = 0
        end
    end

    parseWallObjects(gameMap.layers["walls_obj"])   -- private call
    parseStoneObjects(gameMap.layers["stones_obj"]) -- private call
    parsePlayerSpawn(gameMap.layers["player_obj"])
end

-- public: main.lua calls this
local function draw()
    gameMap:drawLayer(gameMap.layers["background"])
    gameMap:drawLayer(gameMap.layers["walls"])
    drawGrid()
end

local function getSize()
    return mapWidth, mapHeight
end

local function getSpawn()
    return playerSpawnCol, playerSpawnRow
end

local function getStones()
    return stoneList
end

local function getGrid()
    return grid
end
-- what other files actually get to see
return {
    load = load,
    draw = draw,
    isSolid = isSolid,
    getSize = getSize, -- main.lua needs this for camera clamping
    getSpawn = getSpawn,
    getStones = getStones,
    getGrid = getGrid,
    -- parseWallObjects is NOT here - intentionally hidden
}

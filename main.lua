function love.load()
    TILE = 32
    gameFont = love.graphics.newFont("/fonts/Satoshi-Variable.ttf", 15, "normal", 2)

    sti = require("library/Simple-Tiled-Implementation/sti")
    cameraFile = require("library/hump/camera")

    cam = cameraFile()
    cam:zoom(2)

    player = {}
    player.col, player.row = 3, 3
    player.speed = 8

    walls = {}
    stones = {}
    
    grid = {}

    loadMap("ankgor_watt_intro_level")
end

function love.update() 
    local zoomLevel = 2
    local halfW = (love.graphics.getWidth() / 2) / zoomLevel
    local halfH = (love.graphics.getHeight() / 2) / zoomLevel

    local px = player.col * TILE + TILE / 2
    local py = player.row * TILE + TILE / 2

    local camX = math.max(halfW, math.min(px, mapWidth * TILE - halfW))
    local camY = math.max(halfH, math.min(py, mapHeight * TILE - halfH))

    cam:lookAt(camX, camY)
end

function love.draw()
    cam:attach()
    gameMap:drawLayer(gameMap.layers["background"])
    gameMap:drawLayer(gameMap.layers["walls"])
    gameMap:drawLayer(gameMap.layers["statues"])

    drawGrid()

    local px = player.col * TILE
    local py = player.row * TILE
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", px, py, TILE, TILE)
    cam:detach()
    love.graphics.setColor(1, 1, 1, 1)
end

function loadMap(mapName) 
    gameMap = sti("levels/" .. mapName .. ".lua")

    mapWidth = gameMap.width
    mapHeight = gameMap.height

    -- Initialize empty grid
    for row = 0, mapHeight - 1 do 
        grid[row] = {}
        for col = 0, mapWidth - 1 do 
            grid[row][col] = 0 -- 0 = empty
        end
    end
    
    for _, obj in pairs(gameMap.layers["walls_obj"].objects) do
        local col = math.floor(obj.x / TILE)
        local row = math.floor(obj.y / TILE)
        local cols = math.floor(obj.width / TILE)
        local rows = math.floor(obj.height / TILE)
        for r = row, row + rows - 1 do 
            for c = col, col + cols - 1 do 
                if grid[r] then grid[r][c] = 1 end -- 1 = solid wall
            end
        end
    end
    
    for _, obj in pairs(gameMap.layers["stones_obj"].objects) do
        local col = math.floor(obj.x / TILE)
        local row = math.floor(obj.y / TILE)
        local cols = math.floor(obj.width / TILE)
        local rows = math.floor(obj.height / TILE)
        for r = row, row + rows - 1 do 
            for c = col, col + cols - 1 do 
                if grid[r] then grid[r][c] = 2 end --2 = solid rock
            end
        end
    end
    
    for _, obj in pairs(gameMap.layers["player_obj"].objects) do
        player.col = math.floor(obj.x / TILE)
        player.row = math.floor(obj.y / TILE)
    end
end

function drawGrid() 
    for row = 0, mapHeight - 1 do 
        for col = 0, mapWidth - 1 do 
            local x =  col * TILE
            local y = row * TILE
            local cell = grid[row][col]

            if cell == 1 then 
                love.graphics.setColor(1, 0, 0, 0.3)
                love.graphics.rectangle("fill", x, y, TILE, TILE)
            end

            -- grid lines
            love.graphics.setColor(1, 1, 1, 0.15)
            love.graphics.rectangle("line", x, y, TILE, TILE)

            -- cell coordinates
            love.graphics.setColor(1, 1, 1, 0.4)
            love.graphics.print(col .. "," .. row, x + 2, y + 2)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function love.keypressed(key) 
    local dc, dr = 0, 0
    if key == "right" or key == "d" then 
        dc = 1
    elseif key == "left" or key == "a" then
        dc = -1
    elseif key == "down" or key == "s" then
        dr = 1
    elseif key == "up" or key == "w" then
        dr = -1
    end

    local targetCol = player.col + dc
    local targetRow = player.row + dr

    if isSolid(targetCol, targetRow) then 
        -- blocked, do nothing
    else 
        player.col = targetCol
        player.row = targetRow
    end
end

function isSolid(col, row)
    if row < 0 or col < 0 or row >= mapHeight or col >= mapWidth then 
        return true
    end
    return grid[row][col] == 1
end
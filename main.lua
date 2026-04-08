function love.load()
    gameFont = love.graphics.newFont("fonts/Satoshi-Variable.ttf", 15, "normal", 2)

    bump = require("library/bump/bump")
    sti = require("library/Simple-Tiled-Implementation/sti")
    cameraFile = require("library/hump/camera")
    anim8 = require("library/anim8/anim8")

    cam = cameraFile()
    cam:zoom(2)

    world = bump.newWorld(32)

    player = {}
    player.x, player.y = 100, 100
    player.w, player.h = 32, 32
    
    walls = {}
    stones = {}
    
    sprites = {}
    sprites.stoneSprite = love.graphics.newImage("sprites_png/aw_stones_tileset.png")

    local stoneGrid = anim8.newGrid(32, 32, sprites.stoneSprite:getWidth(), sprites.stoneSprite:getHeight())

    animations = {}
    animations.stoneRoll = anim8.newAnimation(stoneGrid('1-3', 1, '1-3', 2, '1-2', 3), 0.1)

    --[[platform = {}
    platform.x, platform.y = 300, 300
    platform.w, platform.h = 256, 64

    world:add(platform, platform.x, platform.y, platform.w, platform.h)]]

    loadMap("ankgor_watt_intro_level")
end

function love.update(dt)
     local zoomLevel = 2
     local halfW = (love.graphics.getWidth() / 2) / zoomLevel
     local halfH = (love.graphics.getHeight() / 2) / zoomLevel

     local camX = math.max(halfW, math.min(player.x, mapWidth - halfW))
     local camY = math.max(halfH, math.min(player.y, mapHeight - halfH))

     cam:lookAt(camX, camY)

     checkStoneGravity()
end

function love.draw()
    cam:attach()
    gameMap:drawLayer(gameMap.layers["background"])
    gameMap:drawLayer(gameMap.layers["walls"])
    gameMap:drawLayer(gameMap.layers["statues"])
    drawStones()
    love.graphics.rectangle("line", player.x, player.y, player.w, player.h)
    for i, wall in ipairs(walls) do 
        love.graphics.rectangle("line", wall.x, wall.y, wall.w, wall.h)
    end
    for i, stone in ipairs(stones) do 
        love.graphics.rectangle("line", stone.x, stone.y, stone.w, stone.h)
    end
    cam:detach()
    love.graphics.setFont(gameFont)
    love.graphics.printf(
        "Player Hitbox: " .. math.floor(player.x) .. ", " .. math.floor(player.y),
        10,
        10,
        love.graphics.getWidth(),
        "left"
    )
end

function love.keypressed(key)
    local dx, dy = 0, 0
    local grid = 32

    if key == "w" or key == "up" then 
        dy = -grid
    elseif key == "a" or key == "left" then
        dx = -grid
    elseif key == "s" or key == "down" then
        dy = grid
    elseif key == "d" or key == "right" then
        dx = grid
    end

    local goalX = player.x + dx
    local goalY = player.y + dy

    local actualX, actualY, cols, len = world:move(player, goalX, goalY)
    --[[if len > 0 then 
        if cols.other.type = "stone" and not col.other.isMoving then
            
        end
    end]]
    player.x = actualX
    player.y = actualY
end

function loadMap(mapName) 
    gameMap = sti("levels/" .. mapName .. ".lua")

    mapWidth = gameMap.width * gameMap.tilewidth
    mapHeight = gameMap.height * gameMap.tileheight

    for i, obj in pairs(gameMap.layers["walls_obj"].objects) do 
        spawnWall(obj.x, obj.y, obj.width, obj.height)
    end

    for i, obj in pairs(gameMap.layers["stones_obj"].objects) do 
        spawnStone(obj.x, obj.y, obj.width, obj.height)
    end

    for i, obj in pairs(gameMap.layers["player_obj"].objects) do 
        player.x = obj.x
        player.y = obj.y
        player.w = obj.width
        player.h = obj.height
    end
    
    world:add(player, player.x, player.y, player.w, player.h)
end

function spawnWall(x, y, width, height) 
    if width > 0 and height > 0 then  
        local wall = {
            x = x,
            y = y,
            w = width,
            h = height,
        }
        world:add(wall, x, y, width, height)
        table.insert(walls, wall)
    end
end

function spawnStone(x, y, width, height) 
    if width > 0 and height > 0 then  
        local stone = {
            x = x,
            y = y,
            w = width,
            h = height,
            type = "stone",
            isMoving = false,
            anim = animations.stoneRoll:clone(),
        }
        world:add(stone, x, y, width, height)
        table.insert(stones, stone)
    end
end

function checkStoneGravity()
    for _, stone in ipairs(stones) do 
        local downY = stone.y + 32
        local actualX, actualY, cols, len = world:move(stone, stone.x, downY)
        stone.x = actualX
        stone.y = actualY
    end
end

function drawStones() 
    for _, s in ipairs(stones) do 
        s.anim:draw(sprites.stoneSprite, s.x, s.y)
    end
end
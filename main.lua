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
	player.targetX, player.targetY = player.x, player.y
	player.startX, player.startY = player.x, player.y
	player.bufferedInput = {}
	player.moveTimer = 0
	player.moveDuration = 0.15
	player.isMoving = false

	walls = {}
	stones = {}
	grassTable = {}

	sprites = {}
	sprites.stoneSprite = love.graphics.newImage("sprites_png/aw_stones_tileset.png")
	sprites.grassSprite = love.graphics.newImage("sprites_png/grass_animation_tileset.png")

	local stoneGrid = anim8.newGrid(32, 32, sprites.stoneSprite:getWidth(), sprites.stoneSprite:getHeight())
	local grassGrid = anim8.newGrid(44, 35, sprites.grassSprite:getWidth(), sprites.grassSprite:getHeight())

	animations = {}
	animations.stoneRoll = anim8.newAnimation(stoneGrid("1-3", 1, "1-3", 2, "1-2", 3), 0.1)
	animations.destroyGrass = anim8.newAnimation(grassGrid("1-8", 1), 0.25)

	loadMap("ankgor_watt_intro_level")
end

function love.update(dt)
	local zoomLevel = 2
	local halfW = (love.graphics.getWidth() / 2) / zoomLevel
	local halfH = (love.graphics.getHeight() / 2) / zoomLevel

	local camX = math.max(halfW, math.min(player.x, mapWidth - halfW))
	local camY = math.max(halfH, math.min(player.y, mapHeight - halfH))

	cam:lookAt(camX, camY)

	if player.isMoving then
		player.moveTimer = math.min(player.moveTimer + dt, player.moveDuration)
		local t = player.moveTimer / player.moveDuration

		player.x = player.startX + (player.targetX - player.startX) * t
		player.y = player.startY + (player.targetY - player.startY) * t

		if t >= 1 then
			player.x, player.y = player.targetX, player.targetY
			player.isMoving = false

			world:update(player, player.x, player.y)

			if #player.bufferedInput > 0 then
				local nextDir = table.remove(player.bufferedInput, 1)
				tryMove(nextDir)
			end
		end
	end

	for _, stone in ipairs(stones) do
		if stone.isMoving then
			stone.moveTimer = math.min(stone.moveTimer + dt, stone.moveDuration)
			local t = stone.moveTimer / stone.moveDuration

			stone.x = stone.startX + (stone.targetX - stone.startX) * t

			if t >= 1 then
				stone.x = stone.targetX
				stone.isMoving = false

				world:update(stone, stone.x, stone.y)
			end
		end
	end
end

function love.draw()
	cam:attach()
	gameMap:drawLayer(gameMap.layers["background"])
	gameMap:drawLayer(gameMap.layers["walls"])
	gameMap:drawLayer(gameMap.layers["statues"])
	drawStones()
	drawGrass()
	love.graphics.rectangle("line", player.x, player.y, player.w, player.h)
	for _, wall in ipairs(walls) do
		love.graphics.rectangle("line", wall.x, wall.y, wall.w, wall.h)
	end
	for _, stone in ipairs(stones) do
		love.graphics.rectangle("line", stone.x, stone.y, stone.w, stone.h)
	end
	for _, grass in ipairs(grassTable) do
		love.graphics.rectangle("line", grass.x, grass.y, grass.w, grass.h)
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
	local fps = love.timer.getFPS()
	love.graphics.print("FPS: " .. fps, 10, 30)
end

function love.keypressed(key)
	-- movement mechanism allows for spam
	local dir = nil

	if key == "w" or key == "up" then
		dir = "up"
	elseif key == "a" or key == "left" then
		dir = "left"
	elseif key == "s" or key == "down" then
		dir = "down"
	elseif key == "d" or key == "right" then
		dir = "right"
	end

	if dir then
		-- if player.isMoving == false
		if not player.isMoving then
			tryMove(dir)
		else
			table.insert(player.bufferedInput, dir)
		end
	end
end

function tryMove(dir)
	local dx, dy = 0, 0
	local grid = 32

	if dir == "up" then
		dy = -grid
	elseif dir == "left" then
		dx = -grid
	elseif dir == "down" then
		dy = grid
	elseif dir == "right" then
		dx = grid
	end

	local goalX = player.x + dx
	local goalY = player.y + dy

	local _, _, cols, len = world:check(player, goalX, goalY)

	local canMove = true
	if len > 0 then
		for i, cols in ipairs(cols) do
			if col.other.type == "stone" and not col.other.isMoving then
				if tryMoveStone(col.other, dir) then
					canMove = true
				else
					canMove = false
				end
			elseif col.other.type == "grass" then
				canMove = true
				-- trigger animation
				-- world:remove(col.other)
				if col.other == grass then
					-- deletion issue
					-- grass = nil
				end
			else
				canMove = false
			end
		end
	end

	if canMove then
		player.isMoving = true
		player.startX = player.x
		player.startY = player.y
		player.targetX = goalX
		player.targetY = goalY
		player.moveTimer = 0
	end
end

-- checks and moves stone(s)
function tryMoveStone(s, dir)
	local dx = 0
	local grid = 32

	if dir == "up" or dir == "down" then
		return false
	end

	if dir == "left" then
		dx = -grid
	elseif dir == "right" then
		dx = grid
	end

	local goalX = s.x + dx

	local _, _, _, len = world:check(s, goalX, s.y)

	if len == 0 then
		s.isMoving = true
		s.startX = s.x
		s.targetX = goalX
		s.moveTimer = 0
		return true
	end
	return false
end

function loadMap(mapName)
	gameMap = sti("levels/" .. mapName .. ".lua")

	mapWidth = gameMap.width * gameMap.tilewidth
	mapHeight = gameMap.height * gameMap.tileheight

	for _, obj in pairs(gameMap.layers["walls_obj"].objects) do
		spawnWall(obj.x, obj.y, obj.width, obj.height)
	end

	for _, obj in pairs(gameMap.layers["stones_obj"].objects) do
		spawnStone(obj.x, obj.y, obj.width, obj.height)
	end

	for _, obj in pairs(gameMap.layers["player_obj"].objects) do
		player.x = obj.x
		player.y = obj.y
		player.w = obj.width
		player.h = obj.height
	end

	world:add(player, player.x, player.y, player.w, player.h)

	for _, obj in pairs(gameMap.layers["grass_obj"].objects) do
		spawnGrass(obj.x, obj.y, obj.width, obj.height)
	end
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
			targetX = x,
			targetY = y,
			startX = x,
			startY = y,
			moveDuration = 0.15,
			moveTimer = 0,
		}
		stone.anim:pause()
		world:add(stone, x, y, width, height)
		table.insert(stones, stone)
	end
end

function spawnGrass(x, y, width, height)
	if width > 0 and height > 0 then
		local grass = {
			x = x,
			y = y,
			w = width,
			h = height,
			type = "grass",
			anim = animations.destroyGrass:clone(),
		}
		grass.anim:pause()
		world:add(grass, x, y, width, height)
		table.insert(grassTable, grass)
	end
end

function checkStoneGravity()
	for _, stone in ipairs(stones) do
		local downY = stone.y + 32
		local actualX, actualY, cols, len = world:move(stone, stone.x, downY)
		stone.isMoving = true
		stone.x = actualX
		stone.y = actualY
	end
end

function drawStones()
	for _, stone in ipairs(stones) do
		stone.anim:draw(sprites.stoneSprite, stone.x, stone.y)
	end
end

function drawGrass()
	for _, grass in ipairs(grassTable) do
		grass.anim:draw(sprites.grassSprite, grass.x, grass.y)
	end
end

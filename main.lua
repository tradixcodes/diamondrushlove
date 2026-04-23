function love.load()
	gameFont = love.graphics.newFont("fonts/Satoshi-Variable.ttf", 15, "normal", 2)

	bump = require("library/bump/bump")
	sti = require("library/Simple-Tiled-Implementation/sti")
	cameraFile = require("library/hump/camera")
	anim8 = require("library/anim8/anim8")

	cam = cameraFile()
	cam:zoom(2)

	world = bump.newWorld(32)

	require("player")
	require("stones")
	require("bush")
	require("utils")

	walls = {}
	stones = {}
	bushTable = {}

	grid = 32

	sprites = {}
	sprites.stoneSprite = love.graphics.newImage("sprites_png/aw_stones_tileset.png")
	sprites.bushSprite = love.graphics.newImage("sprites_png/grass_animation_tileset.png")

	local stoneGrid = anim8.newGrid(32, 32, sprites.stoneSprite:getWidth(), sprites.stoneSprite:getHeight())
	local bushGrid = anim8.newGrid(44, 35, sprites.bushSprite:getWidth(), sprites.bushSprite:getHeight())

	animations = {}
	animations.stoneRoll = anim8.newAnimation(stoneGrid("1-3", 1, "1-3", 2, "1-2", 3), 0.15)
	animations.destroyBush = anim8.newAnimation(bushGrid("1-8", 1), 0.25)

	loadMap("ankgor_watt_intro_level")

	--love.graphics.setDefaultFilter("nearest", "nearest")
end

function love.update(dt)
	local zoomLevel = 2
	local halfW = (love.graphics.getWidth() / 2) / zoomLevel
	local halfH = (love.graphics.getHeight() / 2) / zoomLevel

	local camX = math.max(halfW, math.min(player.x, mapWidth - halfW))
	local camY = math.max(halfH, math.min(player.y, mapHeight - halfH))

	cam:lookAt(camX, camY)

	updatePlayer(dt)
	updateStones(dt)
	updateBush(dt)
end

function love.draw()
	cam:attach()
	gameMap:drawLayer(gameMap.layers["background"])
	gameMap:drawLayer(gameMap.layers["walls"])
	gameMap:drawLayer(gameMap.layers["statues"])
	drawStones()
	-- drawBush()
	drawPlayer()
	for _, wall in ipairs(walls) do
		love.graphics.rectangle("line", wall.x, wall.y, wall.w, wall.h)
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

	--[[for _, obj in pairs(gameMap.layers["grass_obj"].objects) do
		spawnBush(obj.x, obj.y, obj.width, obj.height)
	end]]
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
			isFalling = false,
			fallTimer = 0,
			fallDuration = 0.3,
		}
		stone.anim:pause()
		world:add(stone, x, y, width, height)
		table.insert(stones, stone)
	end
end

function spawnBush(x, y, width, height)
	if width > 0 and height > 0 then
		local bush = {
			x = x,
			y = y,
			w = width,
			h = height,
			type = "bush",
			anim = animations.destroyBush:clone(),
		}
		bush.anim:pause()
		world:add(bush, x, y, width, height)
		table.insert(bushTable, bush)
	end
end

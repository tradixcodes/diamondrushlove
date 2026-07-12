local Map = require("map")

local Player = {}

Player.col = 3
Player.row = 3

Player.isMoving = false
Player.moveSpeed = 8
Player.moveProgress = 0

Player.startX = 0
Player.startY = 0
Player.targetCol = Player.col
Player.targetRow = Player.row

local function load(startCol, startRow)
	Player.col = startCol or Player.col
	Player.row = startRow or Player.row

	Player.width = TILE
	Player.height = TILE
	Player.x = Player.col * TILE
	Player.y = Player.row * TILE
	Player.startX = Player.x
	Player.startY = Player.y
end

local function tryStartMove(dCol, dRow)
	if Player.isMoving then
		return
	end

	local newCol = Player.col + dCol
	local newRow = Player.row + dRow

	if newCol < 0 or newCol > Map.mapWidth - 1 or newRow < 0 or newRow > Map.mapHeight - 1 then
		return -- would walk off the grid, ignore
	end

	Player.startX = Player.x
	Player.startY = Player.y
	Player.targetCol = newCol
	Player.targetRow = newRow
	Player.moveProgress = 0
	Player.isMoving = true
end

local function handleInput()
	if Player.isMoving then
		return
	end -- ignore input mid-slide

	if love.keyboard.isDown("w") then
		tryStartMove(0, -1)
	elseif love.keyboard.isDown("s") then
		tryStartMove(0, 1)
	elseif love.keyboard.isDown("a") then
		tryStartMove(-1, 0)
	elseif love.keyboard.isDown("d") then
		tryStartMove(1, 0)
	end
end

local function update(dt)
	handleInput()

	if Player.isMoving then
		Player.moveProgress = Player.moveProgress + Player.moveSpeed * dt

		if Player.moveProgress >= 1 then
			Player.moveProgress = 1
			Player.isMoving = false
			Player.col = Player.targetCol
			Player.row = Player.targetRow
		end

		local targetX = Player.targetCol * TILE
		local targetY = Player.targetRow * TILE
		Player.x = Player.startX + (targetX - Player.startX) * Player.moveProgress
		Player.y = Player.startY + (targetY - Player.startY) * Player.moveProgress
	end
end

local function draw()
	love.graphics.setColor(1, 0.3, 0.3, 1)
	love.graphics.rectangle("line", Player.x, Player.y, Player.width, Player.height)
	love.graphics.setColor(1, 1, 1, 1)
end

Player.load = load
Player.update = update
Player.draw = draw

return Player

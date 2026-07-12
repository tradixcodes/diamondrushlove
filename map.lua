local DevTools = require("devtools")
local sti = require("library/Simple-Tiled-Implementation/sti")

local grid = {}
local mapWidth = 20
local mapHeight = 20

local currentMap = nil -- holds the STI map object once loaded

local function initializeGrid()
	for r = 0, mapHeight - 1 do
		grid[r] = {}
		for c = 0, mapWidth - 1 do
			grid[r][c] = 0
		end
	end
end

local function loadLevel(path)
	currentMap = sti(path)
end

local function draw()
	if currentMap then
		currentMap:draw()
	end
end

local function drawGrid()
	if not DevTools.showGrid then
		return
	end -- skip entirely if toggled off

	for row = 0, mapHeight - 1 do
		for col = 0, mapWidth - 1 do
			local x = col * TILE
			local y = row * TILE

			love.graphics.setColor(1, 1, 1, 0.3)
			love.graphics.rectangle("line", x, y, TILE, TILE)
		end
	end
	love.graphics.setColor(1, 1, 1, 1)
end

local function update(dt)
	if currentMap then
		currentMap:update(dt)
	end
	-- future: stone physics, player movement, etc.
end

local function getPlayerStart()
	if not currentMap then
		return nil, nil
	end

	for _, layer in ipairs(currentMap.layers) do
		if layer.type == "objectgroup" and layer.name == "player_obj" then
			local obj = layer.objects[1]
			if obj then
				local col = math.floor(obj.x / TILE)
				local row = math.floor(obj.y / TILE)
				return col, row
			end
		end
	end

	return nil, nil
end

return {
	initializeGrid = initializeGrid,
	loadLevel = loadLevel,
	draw = draw,
	drawGrid = drawGrid,
	update = update,
	mapWidth = mapWidth,
	mapHeight = mapHeight,
	getPlayerStart = getPlayerStart,
}

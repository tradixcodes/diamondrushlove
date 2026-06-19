local DevTools = require("devtools")

local grid = {}
local mapWidth = 20
local mapHeight = 20

local function initializeGrid()
	for r = 0, mapHeight - 1 do
		grid[r] = {}
		for c = 0, mapWidth - 1 do
			grid[r][c] = 0
		end
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
	-- future: stone physics, player movement, etc.
end

return {
	initializeGrid = initializeGrid,
	drawGrid = drawGrid,
	update = update,
}

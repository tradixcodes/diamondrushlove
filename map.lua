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
	local gridFont = love.graphics.newFont("fonts/Satoshi-Variable.ttf", 12)
	love.graphics.setFont(gridFont)

	for row = 0, mapHeight - 1 do
		for col = 0, mapWidth - 1 do
			local x = col * TILE
			local y = row * TILE

			love.graphics.setColor(1, 1, 1, 0.15)
			love.graphics.rectangle("line", x, y, TILE, TILE)
			love.graphics.setColor(1, 1, 1, 0.4)
			love.graphics.print(col .. "," .. row, x + 2, y + 2)
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

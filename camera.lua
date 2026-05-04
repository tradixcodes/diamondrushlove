local cameraLib = require("library/hump/camera")

-- private states
local cam = nil
local zoomLevel = 2

-- private helper
local function clamp(value, min, max)
	return math.max(min, math.min(value, max))
end

-- public
local function init()
	cam = cameraLib()
	cam:zoom(zoomLevel)
end

-- public: main.lua calls this each update
local function follow(x, y, mapWidth, mapHeight)
	local halfW = (love.graphics.getWidth() / 2) / zoomLevel
	local halfH = (love.graphics.getHeight() / 2) / zoomLevel

	local camX = clamp(x, halfW, mapWidth * 32 - halfW)
	local camY = clamp(y, halfH, mapHeight * 32 - halfH)

	cam:lookAt(camX, camY)
end

-- public
local function attach()
	cam:attach()
end

-- public
local function detach()
	cam:detach()
end

return {
	init = init,
	follow = follow,
	attach = attach,
	detach = detach,
}

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

    local mapPixelW = mapWidth * 32
    local mapPixelH = mapHeight * 32

    -- If the visible half-extent is >= half the map, centre on that axis
    local camX = (halfW >= mapPixelW / 2)
        and mapPixelW / 2
        or clamp(x, halfW, mapPixelW - halfW)

    local camY = (halfH >= mapPixelH / 2)
        and mapPixelH / 2
        or clamp(y, halfH, mapPixelH - halfH)

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

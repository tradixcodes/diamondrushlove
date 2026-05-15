local TILE         = 32
local STONE        = 2 -- only cell type player handles directly

local Bush         = require("bush")
local Stones       = require("stones")

local col          = 3
local row          = 3

local renderX      = col * TILE
local renderY      = row * TILE
local startX       = renderX
local startY       = renderY
local targetX      = renderX
local targetY      = renderY

local isMoving     = false
local moveTimer    = 0
local moveDuration = 0.12

local map          = nil

local function tryMove(dc, dr)
    if isMoving then return end

    local targetCol = col + dc
    local targetRow = row + dr

    local cell = map.cellAt(targetCol, targetRow)

    if cell == STONE then
        -- stones can only be pushed horizontally and only if the space
        -- beyond them is empty -- tryPush handles both checks
        if dr ~= 0 then return end -- no vertical pushing
        if not Stones.tryPush(targetCol, targetRow, dc) then return end
        -- push succeeded, player walks into the now-empty cell below
    elseif map.isSolid(targetCol, targetRow) then
        return -- wall or out of bounds, block movement
    end

    col = targetCol
    row = targetRow

    Bush.clear(col, row) -- no-op if no bush here

    startX    = renderX
    startY    = renderY
    targetX   = col * TILE
    targetY   = row * TILE
    isMoving  = true
    moveTimer = 0
end

local function init(mapRef)
    map              = mapRef
    col, row         = map.getSpawn()
    renderX          = col * TILE
    renderY          = row * TILE
    startX, startY   = renderX, renderY
    targetX, targetY = renderX, renderY
end

local function update(dt)
    if isMoving then
        moveTimer = math.min(moveTimer + dt, moveDuration)
        local t = moveTimer / moveDuration
        renderX = startX + (targetX - startX) * t
        renderY = startY + (targetY - startY) * t
        if moveTimer >= moveDuration then
            renderX  = targetX
            renderY  = targetY
            isMoving = false
        end
    end
end

local function handleInput(key)
    if key == "right" or key == "d" then
        tryMove(1, 0)
    elseif key == "left" or key == "a" then
        tryMove(-1, 0)
    elseif key == "down" or key == "s" then
        tryMove(0, 1)
    elseif key == "up" or key == "w" then
        tryMove(0, -1)
    end
end

local function getPosition()
    return renderX + TILE / 2, renderY + TILE / 2
end

local function draw()
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.rectangle("fill", renderX, renderY, TILE, TILE)
    love.graphics.setColor(1, 1, 1, 1)
end

return {
    init        = init,
    update      = update,
    draw        = draw,
    handleInput = handleInput,
    getPosition = getPosition,
}

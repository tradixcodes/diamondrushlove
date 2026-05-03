local TILE = 32

-- logical grid position (true position)
local col = 3
local row = 3

-- visual interpolation state
local renderX = col * TILE
local renderY = row * TILE
local startX = renderX
local startY = renderY
local targetX = renderX
local targetY = renderY
local isMoving = false
local moveTimer = 0
local moveDuration = 0.12

local map = nil

local function clampToMap(c, r)
    -- keep player in bounds
end

local function tryMove(dc, dr)
    if isMoving then return end -- ignore input while already isMoving

    local targetCol = col + dc
    local targetRow = row + dr

    if not map.isSolid(targetCol, targetRow) then
        col = targetCol
        row = targetRow

        startX = renderX
        startY = renderY
        targetX = col * TILE
        targetY = row * TILE
        isMoving = true
        moveTimer = 0
    end
end

local function init(mapRef)
    map = mapRef
    col, row = map.getSpawn()
    renderX = col * TILE
    renderY = row * TILE
    startX, startY = renderX, renderY
    targetX, targetY = renderX, renderY
end

local function update(dt)
    if isMoving then
        moveTimer = math.min(moveTimer + dt, moveDuration)
        local t = moveTimer / moveDuration

        -- smoothstep: feels better than linear
        -- t = t * t * (3 - 2 * t)

        renderX = startX + (targetX - startX) * t
        renderY = startY + (targetY - startY) * t

        if moveTimer >= moveDuration then
            renderX = targetX
            renderY = targetY
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
    init = init,
    update = update,
    draw = draw,
    handleInput = handleInput,
    getPosition = getPosition,
    -- tryMove is NOT here - hidden on purpose
    -- col, row are NOT here - nobody gets the raw state
}

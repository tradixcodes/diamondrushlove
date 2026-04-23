-- seperating logic (brain) from the state (body)

-- Returns the dx and dy based on a direction string
-- check if movement needs grid so that we can just define it here instead of having a million locals
function getDirectionOffset(dir)
	local dx, dy = 0, 0
	if dir == "up" then
		dy = -grid
	elseif dir == "down" then
		dy = grid
	elseif dir == "left" then
		dx = -grid
	elseif dir == "right" then
		dx = grid
	end
	return dx, dy
end

-- checks if you can push entities like stones, etc ...
function canPushEntity(e, dir)
	if dir == "up" or dir == "down" then
		return false
	end

	local dx, dy = getDirectionOffset(dir)
	local goalX, goalY = e.x + dx, e.y + dy

	local _, _, _, len = world:check(e, goalX, goalY)
	return len == 0
end

function canEntityFall(e)
	local downY = e.y + grid

	local _, _, _, len = world:check(e, e.x, downY)

	return len == 0
end

function applyGravity(e)
	e.isFalling = true
	e.startY = e.y
	e.targetY = e.y + grid
	e.fallTimer = 0
	e.fallDuration = 0.3

	e.anim:gotoFrame(1)
	e.anim:resume()
end

function getEntitySlipDir(e)
    local downY = e.y + grid
    local left, right = e.x - grid, e.x + grid

    local function notSelf(item, other)
        return other ~= e
    end

    local lSideCols, lSide = world:queryRect(left,  e.y,   grid, grid, notSelf)
    local lDiagCols, lDiag = world:queryRect(left,  downY, grid, grid, notSelf)
    local rSideCols, rSide = world:queryRect(right, e.y,   grid, grid, notSelf)
    local rDiagCols, rDiag = world:queryRect(right, downY, grid, grid, notSelf)

    local canSlipLeft  = (lSide == 0 and lDiag == 0)
    local canSlipRight = (rSide == 0 and rDiag == 0)

    --[[local function printCols(label, cols)
        for i = 1, #cols do
            local item = cols[i]  -- queryRect returns items directly, no .other
            local ox, oy, ow, oh = world:getRect(item)
            -print(string.format(
                "%s hit: [%s] at x=%.2f y=%.2f w=%.2f h=%.2f",
                label,
                tostring(item.type),
                ox, oy, ow, oh
            ))
        end
    end

    print(string.format(
        "Entity at x=%.2f y=%.2f | Querying: left=%.2f right=%.2f downY=%.2f",
        e.x, e.y, left, right, downY
    ))
    print(string.format(
        "L-Side: %d, L-Diag: %d, R-Side: %d, R-Diag: %d",
        lSide, lDiag, rSide, rDiag
    ))
    printCols("lSide", lSideCols)
    printCols("lDiag", lDiagCols)
    printCols("rSide", rSideCols)
    printCols("rDiag", rDiagCols)
    ]]

    if canSlipLeft and canSlipRight then
        return love.math.random() > 0.5 and "left" or "right"
    elseif canSlipLeft then
        return "left"
    elseif canSlipRight then
        return "right"
    end
    return nil
end
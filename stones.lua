love.math.setRandomSeed(os.time())

function updateStones(dt)
	for _, s in ipairs(stones) do
		s.anim:update(dt)
		if s.isMoving then
			s.moveTimer = math.min(s.moveTimer + dt, s.moveDuration)
			local t = s.moveTimer / s.moveDuration

			s.x = s.startX + (s.targetX - s.startX) * t
			world:update(s, s.x, s.y)

			if t >= 1 then
				s.x = s.targetX
				s.isMoving = false
				s.anim:pause()
			end
		elseif s.isFalling then
			s.fallTimer = math.min(s.fallTimer + dt, s.fallDuration)
			local t = s.fallTimer / s.fallDuration

			s.y = s.startY + (s.targetY - s.startY) * t
			world:update(s, s.x, s.y)

			if t >= 1 then
				s.y = s.targetY
				s.isFalling = false
				s.anim:pause()
			end
		else
			if canEntityFall(s) then
				applyGravity(s)
			else
				checkAutonomousSlip(s)
			end
		end
	end
end

function drawStones()
	for _, stone in ipairs(stones) do
		love.graphics.rectangle("line", stone.x, stone.y, stone.w, stone.h)
	end
	for _, stone in ipairs(stones) do
		stone.anim:draw(sprites.stoneSprite, stone.x, stone.y)
	end
end

-- moves stone(s)
function moveStone(s, dir)
	if canPushEntity(s, dir) == true then
		local dx = getDirectionOffset(dir)

		local goalX = s.x + dx

		s.isMoving = true
		s.startX = s.x
		s.targetX = goalX
		s.moveTimer = 0

		s.anim:gotoFrame(1)
		s.anim:resume()
	end
end

function checkAutonomousSlip(s)
	if s.isMoving or s.isFalling then
		return
	end

	local _, _, cols, _ = world:check(s, s.x, s.y + grid)
	local onStone = false
	for _, col in ipairs(cols) do
		if col.other.type == "stone" and not col.other.isMoving and not col.other.isFalling then
			onStone = true
			break
		end
	end

	if onStone then
		local slipDir = getEntitySlipDir(s)
		if slipDir then
			applyStoneSlip(s, slipDir)
		end
	end
end

function applyStoneSlip(s, dir)
	s.isMoving = true
	s.startX = s.x
	s.targetX = (dir == "right") and (s.x + grid) or (s.x - grid)
	s.moveTimer = 0
	s.moveDuration = 0.15

	s.anim:gotoFrame(1)
	s.anim:resume()
end

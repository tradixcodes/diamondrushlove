-- stones.lua
love.math.setRandomSeed(os.time())

function updateStones(dt)
	for _, s in ipairs(stones) do
		s.anim:update(dt)
		updateStoneJitter(s, dt)

		if s.isMoving then
			s.moveTimer = math.min(s.moveTimer + dt, s.moveDuration)
			local t = s.moveTimer / s.moveDuration
			s.x = s.startX + (s.targetX - s.startX) * t
			world:update(s, s.x, s.y)

			-- asymmetric dip: cuts in fast, eases out slowly
			local dip
			if t < 0.4 then
				dip = t / 0.4
			else
				dip = 1 - ((t - 0.4) / 0.6)
			end
			s.visualOffsetY = dip * (s.slipDipHeight or 0)

			-- slight horizontal lead to reinforce the diagonal feel
			local horizontalLead = (s.targetX > s.startX) and 3 or -3
			s.visualOffsetX = math.sin(t * math.pi) * horizontalLead * ((s.slipDipHeight or 0) > 0 and 1 or 0)

			if t >= 1 then
				s.x = s.targetX
				s.isMoving = false
				s.visualOffsetY = 0
				s.visualOffsetX = 0
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
		local ox = (stone.jitterOffsetX or 0) + (stone.visualOffsetX or 0)
		local oy = (stone.jitterOffsetY or 0) + (stone.visualOffsetY or 0)
		stone.anim:draw(sprites.stoneSprite, stone.x + ox, stone.y + oy)
	end
end

function moveStone(s, dir)
	if not canPushEntity(s, dir) then return end

	local dx = getDirectionOffset(dir)
	s.isMoving = true
	s.startX = s.x
	s.targetX = s.x + dx
	s.moveTimer = 0
	s.slipDipHeight = 0   -- pushed stones don't dip, only slipping ones do
	s.visualOffsetY = 0
	s.visualOffsetX = 0
	s.anim:gotoFrame(1)
	s.anim:resume()
end

function checkAutonomousSlip(s)
	if s.isMoving or s.isFalling or s.isJittering then return end

	local _, _, cols, _ = world:check(s, s.x, s.y + grid)
	local onStone = false

	for _, col in ipairs(cols) do
		if col.other.type == "stone"
			and not col.other.isMoving
			and not col.other.isFalling
		then
			onStone = true
			break
		end
	end

	if not onStone then return end

	local slipDir = getEntitySlipDir(s)
	if slipDir then
		beginStoneJitter(s, slipDir)
	end
end

function beginStoneJitter(s, dir)
	s.isJittering = true
	s.jitterDir = dir
	s.jitterTimer = 0
	s.jitterDuration = 0.3
	s.jitterMag = 2
	s.jitterOffsetX = 0
	s.jitterOffsetY = 0
end

function updateStoneJitter(s, dt)
	if not s.isJittering then return end

	s.jitterTimer = s.jitterTimer + dt
	local progress = s.jitterTimer / s.jitterDuration

	local mag = s.jitterMag * (1 - progress)
	s.jitterOffsetX = love.math.random(-mag * 10, mag * 10) / 10
	s.jitterOffsetY = love.math.random(-mag * 10, mag * 10) / 10

	if s.jitterTimer >= s.jitterDuration then
		s.isJittering = false
		s.jitterOffsetX = 0
		s.jitterOffsetY = 0
		applyStoneSlip(s, s.jitterDir)
	end
end

function applyStoneSlip(s, dir)
	s.isMoving = true
	s.startX = s.x
	s.targetX = (dir == "right") and (s.x + grid) or (s.x - grid)
	s.moveTimer = 0
	s.moveDuration = 0.15
	s.slipDipHeight = 5
	s.visualOffsetY = 0
	s.visualOffsetX = 0
	s.anim:gotoFrame(1)
	s.anim:resume()
end
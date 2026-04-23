player = {}
player.x, player.y = 100, 100
player.w, player.h = 32, 32
player.targetX, player.targetY = player.x, player.y
player.startX, player.startY = player.x, player.y
player.moveTimer = 0
player.moveDuration = 0.15
player.isMoving = false

function updatePlayer(dt)
	if player.isMoving then
		player.moveTimer = math.min(player.moveTimer + dt, player.moveDuration)
		local t = player.moveTimer / player.moveDuration

		player.x = player.startX + (player.targetX - player.startX) * t
		player.y = player.startY + (player.targetY - player.startY) * t

		-- update player postion directly to avoid clipping
		world:update(player, player.x, player.y)

		if t >= 1 then
			player.x, player.y = player.targetX, player.targetY
			player.isMoving = false

			world:update(player, player.targetX, player.targetY)
		end
	end
end

function drawPlayer()
	love.graphics.rectangle("line", player.x, player.y, player.w, player.h)
end

function canPlayerMove(dir)
	local dx, dy = getDirectionOffset(dir)

	local goalX = player.x + dx
	local goalY = player.y + dy

	local _, _, cols, len = world:check(player, goalX, goalY)

	if len == 0 then
		return true
	end

	for _, col in ipairs(cols) do
		local other = col.other

		if other.type == "stone" then
			if not other.isMoving and not other.isFalling and canPushEntity(other, dir) then
				--trigger stone movement
				moveStone(other, dir)
			else
				return false
			end
		elseif other.type == "grass" then
		else
			return false
		end
	end
end

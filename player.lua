player = {}
player.x, player.y = 100, 100
player.w, player.h = 32, 32
player.targetX, player.targetY = player.x, player.y
player.startX, player.startY = player.x, player.y
player.bufferedInput = {}
player.moveTimer = 0
player.moveDuration = 0.15
player.isMoving = false

function updatePlayer(dt) 
    if player.isMoving then
		player.moveTimer = math.min(player.moveTimer + dt, player.moveDuration)
		local t = player.moveTimer / player.moveDuration

		player.x = player.startX + (player.targetX - player.startX) * t
		player.y = player.startY + (player.targetY - player.startY) * t

		if t >= 1 then
			player.x, player.y = player.targetX, player.targetY
			player.isMoving = false

			-- update player postion directly to avoid cliiping
			world:update(player, player.targetX, player.targetY)

			if #player.bufferedInput > 0 then
				local nextDir = table.remove(player.bufferedInput, 1)
				tryMove(nextDir)
			end
		end
	end
end
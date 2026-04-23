function updateBush(dt) end

--[[
 function drawBush()
	for _, bush in ipairs(bushTable) do
		love.graphics.rectangle("line", bush.x, bush.y, bush.w, bush.h)
	end
	for _, bush in ipairs(bushTable) do
		bush.anim:draw(sprites.bushSprite, bush.x, bush.y)
	end
end
]]

function love.keypressed(key)
	local dir = nil

	if key == "w" or key == "up" then
		dir = "up"
	elseif key == "a" or key == "left" then
		dir = "left"
	elseif key == "s" or key == "down" then
		dir = "down"
	elseif key == "d" or key == "right" then
		dir = "right"
	end

	return dir
end

local json = require("library/json/json")

local UISave = {}

function UISave.save(data)
	love.filesystem.write("settings.json", json.encode(data))
end

function UISave.load()
	if love.filesystem.getInfo("settings.json") then
		local raw = love.filesystem.read("settings.json")
		return json.decode(raw)
	end
	return nil
end

return UISave

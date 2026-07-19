local UISave = require("ui_save")
local DevTools = require("devtools")

local UIState = {}

UIState.viewModes = { "fit", "fill", "stretch" }
UIState.currentMode = 2

UIState.credits = {
	"FONTS",
	"BoldPixels — Yūki",
	"@YukiPixels",
	"",
	"MUSIC",
	"Track Name — Artist Name",
	"",
	"SFX",
	"Sound Name — Artist Name",
	"",
	"SPECIAL THANKS",
	"Someone — for something",
	"",
	"",
}

UIState.state = "main"
UIState.selected = 1

UIState.mainItems = { "CONTINUE", "OPTIONS", "CREDITS", "EXIT" }
UIState.optionItems = { "VIEW MODE", "DEV OPTIONS", "BACK" }
UIState.pauseItems = { "RESUME", "OPTIONS", "EXIT TO MENU" }
UIState.devItems = { "GRID", "FPS", "COORDS", "BACK" }

UIState.optionsCaller = "main"
UIState.devCaller = "options"

UIState.creditScroll = 0
UIState.creditSpeed = 30

local function navigate(key, itemCount)
	if key == "up" then
		UIState.selected = (UIState.selected - 2) % itemCount + 1
	elseif key == "down" then
		UIState.selected = UIState.selected % itemCount + 1
	end
end

function UIState.keypressed(key, virtualHeight)
	if UIState.state == "main" then
		navigate(key, #UIState.mainItems)
		if key == "return" or key == "space" then
			local choice = UIState.mainItems[UIState.selected]
			if choice == "CONTINUE" then
				UIState.state = "game"
			elseif choice == "OPTIONS" then
				UIState.optionsCaller = "main"
				UIState.state = "options"
				UIState.selected = 1
			elseif choice == "CREDITS" then
				UIState.state = "credits"
				UIState.creditScroll = virtualHeight
			elseif choice == "EXIT" then
				love.event.quit()
			end
		end
	elseif UIState.state == "options" then
		navigate(key, #UIState.optionsItems)
		if key == "return" or key == "space" then
			local choice = UIState.optionsItems[UIState.selected]
			if choice == "VIEW MODE" then
				if key == "return" then
					UIState.currentMode = (UIState.currentMode - 2) % #UIState.viewModes + 1
				end
				UIState.saveSettings()
			elseif choice == "DEV OPTIONS" then
				UIState.state = "dev"
				UIState.selected = 1
			elseif choice == "BACK" then
				UIState.state = UIState.optionsCaller
				UIState.selected = 1
			end
		end
	elseif UIState.state == "credits" then
		if key == "escape" or key == "return" or key == "backspace" then
			UIState.state = "main"
			UIState.selected = 1
		end
	elseif UIState.state == "game" then
		if key == "escape" then
			UIState.state = "pause"
			UIState.selected = 1
		end
	elseif UIState.state == "pause" then
		navigate(key, #UIstate.pauseItems)
		if key == "return" or key == "space" then
			local choice = UIState.pauseItems[UIState.selected]
			if choice == "RESUME" then
				UIState.state = "game"
				UIState.selected = 1
			elseif choice == "OPTIONS" then
				UIState.optionsCaller = "pause"
				UIState.state = "options"
				UIState.selected = 1
			elseif choice == "EXIT TO MENU" then
				UIState.state = "main"
				UIState.selected = 1
			end
		elseif key == "escape" then
			UIState.state = "game"
			UIState.selected = 1
		end
	elseif UIState.state == "dev" then
		navigate(key, #UIState.devItems)
		if key == "return" or key == "space" then
			local choice = UIState.devItems[UIState.selected]
			if choice == "GRID" then
				DevTools.showGrid = not DevTools.showGrid
				UIState.saveSettings()
			elseif choice == "FPS" then
				DevTools.showFPS = not DevTools.showFPS
				UIState.saveSettings()
			elseif choice == "COORDS" then
				DevTools.showCoords = not DevTools.showCoords
				UIState.saveSettings()
			elseif choice == "BACK" then
				UIState.state = "options"
				UIState.selected = 1
			end
		end
	end
end

function UIState.update(dt, virtualHeight)
	if UIState.state == "credits" then
		UIState.creditScroll = UIState.creditScroll - (UIState.creditSpeed * dt)
		if UIState.creditScroll < -#UIState.credits * 18 then
			UIState.creditScroll = virtualHeight
		end
	end
end

function UIState.saveSettings()
	UISave.save({
		currentMode = UIState.currentMode,
		showGrid = DevTools.showGrid,
		showFPS = DevTools.showFPS,
		showCoords = DevTools.showCoords,
	})
end

function UIState.loadSettings()
	local data = UISave.load()
	if data then
		if data.currentMode then
			UIState.currentMode = data.currentMode
		end
		if data.showGrid ~= nil then
			DevTools.showGrid = data.showGrid
		end
		if data.showFPS ~= nil then
			DevTools.showFPS = data.showFPS
		end
		if data.showCoords ~= nil then
			DevTools.showCoords = data.showCoords
		end
	end
end

return UIState

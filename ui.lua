local Canvas = require("canvas")
local UISave = require("ui_save")
local DevTools = require("devtools")
local UI = {}

UI.viewModes = { "fit", "fill", "stretch" }
UI.currentMode = 2

UI.credits = {
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

UI.state = "main"
UI.selected = 1

local mainItems = { "CONTINUE", "OPTIONS", "CREDITS", "EXIT" }
local optionItems = { "VIEW MODE", "DEV OPTIONS", "BACK" }
local pauseItems = { "RESUME", "OPTIONS", "EXIT TO MENU" }
local devItems = { "GRID", "FPS", "COORDS", "BACK" }

local optionsCaller = "main"
local devCaller = "options"

local creditScroll = 0
local creditSpeed = 30

local font = nil
local arrow = nil

function UI.load()
	UI.loadSettings()
	font = love.graphics.newFont("fonts/BoldPixels.ttf", 24, "normal", 2)
	arrow = love.graphics.newImage("sprites_png/menu_arrow.png")
end

local function navigate(key, itemCount)
	if key == "up" then
		UI.selected = (UI.selected - 2) % itemCount + 1
	elseif key == "down" then
		UI.selected = UI.selected % itemCount + 1
	end
end

function UI.keypressed(key)
	if UI.state == "main" then
		navigate(key, #mainItems)
		if key == "return" or key == "space" then
			local choice = mainItems[UI.selected]
			if choice == "CONTINUE" then
				UI.state = "game"
			elseif choice == "OPTIONS" then
				optionsCaller = "main"
				UI.state = "options"
				UI.selected = 1
			elseif choice == "CREDITS" then
				UI.state = "credits"
				creditScroll = Canvas.VIRTUAL_H
			elseif choice == "EXIT" then
				love.event.quit()
			end
		end
	elseif UI.state == "options" then
		navigate(key, #optionItems)
		if key == "return" or key == "space" or key == "left" or key == "right" then
			local choice = optionItems[UI.selected]
			if choice == "VIEW MODE" then
				if key == "left" then
					UI.currentMode = (UI.currentMode - 2) % #UI.viewModes + 1
				else
					UI.currentMode = (UI.currentMode % #UI.viewModes) + 1
				end
				UI.saveSettings()
			elseif choice == "DEV OPTIONS" then
				UI.state = "dev"
				UI.selected = 1
			elseif choice == "BACK" then
				UI.state = optionsCaller
				UI.selected = 1
			end
		end
	elseif UI.state == "credits" then
		if key == "escape" or key == "return" or key == "backspace" then
			UI.state = "main"
			UI.selected = 1
		end
	elseif UI.state == "game" then
		if key == "escape" then
			UI.state = "pause"
			UI.selected = 1
		end
	elseif UI.state == "pause" then
		navigate(key, #pauseItems)
		if key == "return" or key == "space" then
			local choice = pauseItems[UI.selected]
			if choice == "RESUME" then
				UI.state = "game"
				UI.selected = 1
			elseif choice == "OPTIONS" then
				optionsCaller = "pause"
				UI.state = "options"
				UI.selected = 1
			elseif choice == "EXIT TO MENU" then
				UI.state = "main"
				UI.selected = 1
			end
		elseif key == "escape" then
			UI.state = "game"
			UI.selected = 1
		end
	elseif UI.state == "dev" then
		navigate(key, #devItems)
		if key == "return" or key == "space" then
			local choice = devItems[UI.selected]
			if choice == "GRID" then
				DevTools.showGrid = not DevTools.showGrid
				UI.saveSettings()
			elseif choice == "FPS" then
				DevTools.showFPS = not DevTools.showFPS
				UI.saveSettings()
			elseif choice == "COORDS" then
				DevTools.showCoords = not DevTools.showCoords
				UI.saveSettings()
			elseif choice == "BACK" then
				UI.state = "options"
				UI.selected = 1
			end
		end
	end
end

function UI.update(dt)
	if UI.state == "credits" then
		creditScroll = creditScroll - (creditSpeed * dt)
		if creditScroll < -#UI.credits * 18 then
			creditScroll = Canvas.VIRTUAL_H
		end
	end
end

-- ============================================================
-- DRAW HELPERS
-- ============================================================

-- returns the safe visible area of the canvas accounting for fill-mode cropping
local function getSafe()
	local winW, winH = love.graphics.getDimensions()
	return Canvas.getSafeArea(winW, winH)
end

-- horizontally centers text within the safe area
local function centerX(text, safe)
	return safe.left + (safe.width - font:getWidth(text)) / 2
end

local function drawMenuItem(text, x, y, isSelected)
	if isSelected then
		love.graphics.setColor(1, 1, 1, 1)
		local gap = 2
		local w = arrow:getWidth()
		love.graphics.draw(arrow, x - gap - w, y, 0, -1, 1)
		love.graphics.draw(arrow, x + font:getWidth(text) + gap + w, y, 0, 1, 1)
	else
		love.graphics.setColor(0.45, 0.45, 0.45, 1)
	end
	love.graphics.print(text, x, y)
	love.graphics.setColor(1, 1, 1, 1)
end

-- generic menu renderer: title near the top of the safe area, items centered vertically
-- pass labels as a pre-built table so callers can customise display text before calling
local function drawMenu(title, labels, selectedIndex)
	local safe = getSafe()
	local spacing = 36
	local totalH = #labels * spacing
	local startY = safe.centerY - totalH / 2 -- vertically center the item block

	love.graphics.setFont(font)

	if title then
		love.graphics.setColor(1, 0.55, 0, 1)
		love.graphics.print(title, centerX(title, safe), safe.top + 16) -- title sits near the top of the visible area
		love.graphics.setColor(1, 1, 1, 1)
	end

	for i, label in ipairs(labels) do
		local tx = centerX(label, safe)
		local ty = startY + (i - 1) * spacing
		drawMenuItem(label, tx, ty, selectedIndex == i)
	end
end

-- ============================================================
-- DRAW SCREENS
-- ============================================================

local function drawMain()
	drawMenu(nil, mainItems, UI.selected) -- main menu has no title, just the item list
end

local function drawOptions()
	-- build display labels so VIEW MODE shows its current value inline
	local labels = {}
	for _, item in ipairs(optionItems) do
		if item == "VIEW MODE" then
			labels[#labels + 1] = "VIEW: " .. string.upper(UI.viewModes[UI.currentMode])
		else
			labels[#labels + 1] = item
		end
	end
	drawMenu("OPTIONS", labels, UI.selected)
end

local function drawPause()
	-- draw the darkened game-world overlay before the menu
	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 0, 0, Canvas.VIRTUAL_W, Canvas.VIRTUAL_H)
	love.graphics.setColor(1, 1, 1, 1)
	drawMenu("PAUSED", pauseItems, UI.selected)
end

local function drawDev()
	-- build labels with ON/OFF state shown inline for each toggle
	local labels = {
		"GRID:   " .. (DevTools.showGrid and "ON" or "OFF"),
		"FPS:    " .. (DevTools.showFPS and "ON" or "OFF"),
		"COORDS: " .. (DevTools.showCoords and "ON" or "OFF"),
		"BACK",
	}
	drawMenu("DEV OPTIONS", labels, UI.selected)
end

local function drawCredits()
	local safe = getSafe()
	local lineH = 18

	love.graphics.setFont(font)
	love.graphics.setColor(1, 0.55, 0, 1)
	love.graphics.print("CREDITS", centerX("CREDITS", safe), safe.top + 16)
	love.graphics.setColor(1, 1, 1, 1)

	for i, line in ipairs(UI.credits) do
		local y = creditScroll + (i - 1) * lineH
		if y > 30 and y < Canvas.VIRTUAL_H + lineH then
			if line ~= "" then
				local isHeader = (line == line:upper() and not line:find("—"))
				love.graphics.setColor(isHeader and { 1, 0.55, 0, 1 } or { 0.85, 0.85, 0.85, 1 })
				love.graphics.print(line, centerX(line, safe), y)
			end
		end
	end

	love.graphics.setColor(0.4, 0.4, 0.4, 1)
	local hint = "PRESS BACK TO RETURN"
	love.graphics.print(hint, centerX(hint, safe), safe.bottom - 20)
	love.graphics.setColor(1, 1, 1, 1)
end

-- ============================================================
-- CANVAS SCALING
-- ============================================================

function UI.drawCanvas(buffer, vw, vh)
	local winW, winH = love.graphics.getDimensions()
	local mode = UI.viewModes[UI.currentMode]
	local scale, ox, oy = 1, 0, 0

	if mode == "fit" then
		scale = math.min(winW / vw, winH / vh)
		ox = (winW - vw * scale) / 2
		oy = (winH - vh * scale) / 2
		love.graphics.draw(buffer, ox, oy, 0, scale, scale)
	elseif mode == "fill" then
		scale = math.max(winW / vw, winH / vh)
		ox = (winW - vw * scale) / 2
		oy = (winH - vh * scale) / 2
		love.graphics.setScissor(0, 0, winW, winH)
		love.graphics.draw(buffer, ox, oy, 0, scale, scale)
		love.graphics.setScissor()
	elseif mode == "stretch" then
		love.graphics.draw(buffer, 0, 0, 0, winW / vw, winH / vh)
	end
end

function UI.draw()
	love.graphics.setFont(font)
	if UI.state == "main" then
		drawMain()
	elseif UI.state == "options" then
		drawOptions()
	elseif UI.state == "credits" then
		drawCredits()
	elseif UI.state == "pause" then
		drawPause()
	elseif UI.state == "dev" then
		drawDev()
	end
end

-- ============================================================
-- HELPERS
-- ============================================================

function UI.isInGame()
	return UI.state == "game"
end

function UI.isPaused()
	return UI.state == "pause"
end

function UI.cycleView()
	UI.currentMode = (UI.currentMode % #UI.viewModes) + 1
end

function UI.saveSettings()
	UISave.save({
		currentMode = UI.currentMode,
		showGrid = DevTools.showGrid,
		showFPS = DevTools.showFPS,
		showCoords = DevTools.showCoords,
	})
end

function UI.loadSettings()
	local data = UISave.load()
	if data then
		if data.currentMode then
			UI.currentMode = data.currentMode
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

return UI

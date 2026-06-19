local Canvas = require("canvas") -- virtual resolution constants (VIRTUAL_W, VIRTUAL_H)
local UISave = require("ui_save") -- handles reading/writing settings.json
local UI = {}

UI.viewModes = { "fit", "fill", "stretch" } -- ordered list of scaling modes the player can cycle through
UI.currentMode = 2 -- default to "fill" (index 2)

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

UI.state = "main" -- which screen is currently active: "main" | "options" | "credits" | "game"
UI.selected = 1 -- which menu item the cursor is on (1-based index)

local mainItems = { "CONTINUE", "OPTIONS", "CREDITS", "EXIT" } -- items shown on the main menu
local optionItems = { "VIEW MODE", "BACK" } -- items shown in the options screen
local pauseItems = { "RESUME", "OPTIONS", "EXIT TO MENU" }

local optionsCaller = "main" -- remembers which state opened the options screen

local creditScroll = 0 -- current Y offset of the credits text, decremented each frame to scroll upward
local creditSpeed = 30 -- how many pixels per second the credits scroll

local font = nil -- loaded in UI.load, kept nil until LÖVE is ready
local arrow = nil -- arrow sprite drawn on either side of the selected menu item

function UI.load()
	UI.loadSettings() -- apply saved settings before anything is drawn

	font = love.graphics.newFont("fonts/BoldPixels.ttf", 20) -- load the pixel font at 24px
	arrow = love.graphics.newImage("sprites_png/menu_arrow.png") -- load the menu cursor arrow sprite
	love.graphics.setDefaultFilter("nearest", "nearest") -- disable smoothing so pixel art stays sharp
end

-- moves the cursor up or down, wrapping around at either end of the list
local function navigate(key, itemCount)
	if key == "up" then
		UI.selected = (UI.selected - 2) % itemCount + 1 -- subtract 1 in 0-based space, wrap, convert back to 1-based
	elseif key == "down" then
		UI.selected = UI.selected % itemCount + 1 -- advance 1, wrapping index 'itemCount' back to 1
	end
end

function UI.keypressed(key)
	if UI.state == "main" then
		navigate(key, #mainItems) -- move cursor up/down through the main menu with wrapping

		if key == "return" or key == "space" then
			local choice = mainItems[UI.selected] -- read whichever item the cursor is currently on

			if choice == "CONTINUE" then
				UI.state = "game" -- hand control back to the game
			elseif choice == "OPTIONS" then
				optionsCaller = "main" -- came from main menu
				UI.state = "options" -- switch to the options screen
				UI.selected = 1 -- reset cursor to the first option
			elseif choice == "CREDITS" then
				UI.state = "credits" -- switch to the credits screen
				creditScroll = Canvas.VIRTUAL_H -- reset scroll so credits start from the bottom
			elseif choice == "EXIT" then
				love.event.quit() -- close the game
			end
		end
	elseif UI.state == "options" then
		navigate(key, #optionItems) -- move cursor up/down through options with wrapping

		if key == "return" or key == "space" or key == "left" or key == "right" then
			local choice = optionItems[UI.selected]

			if choice == "VIEW MODE" then
				if key == "left" then
					UI.currentMode = (UI.currentMode - 2) % #UI.viewModes + 1 -- cycle backward through view modes
				else
					UI.currentMode = (UI.currentMode % #UI.viewModes) + 1 -- cycle forward through view modes
				end
				UI.saveSettings() -- persist the new mode immediately so it survives a restart
			elseif choice == "BACK" then
				UI.state = optionsCaller -- return to the main menu
				UI.selected = 1 -- reset cursor so it doesn't carry over from options
			end
		end
	elseif UI.state == "credits" then
		if key == "escape" or key == "return" or key == "backspace" then
			UI.state = "main" -- any confirm/back key exits the credits
			UI.selected = 1
		end
	elseif UI.state == "game" then
		if key == "escape" then
			UI.state = "pause" -- pause when escape is pressed during gameplay
			UI.selected = 1
		end
	elseif UI.state == "pause" then
		navigate(key, #pauseItems)

		if key == "return" or key == "space" then
			local choice = pauseItems[UI.selected]

			if choice == "RESUME" then
				UI.state = "game" -- unpause, game continues from where it was
				UI.selected = 1
			elseif choice == "OPTIONS" then
				optionsCaller = "pause" -- came from the pause menu
				UI.state = "options"
				UI.selected = 1
			elseif choice == "EXIT TO MENU" then
				UI.state = "main" -- intentional full exit back to menu
				UI.selected = 1
			end
		elseif key == "escape" then
			UI.state = "game" -- escape while paused also resumes
			UI.selected = 1
		end
	end
end

function UI.update(dt)
	if UI.state == "credits" then
		creditScroll = creditScroll - (creditSpeed * dt) -- move all credit lines upward each frame

		if creditScroll < -#UI.credits * 18 then
			creditScroll = Canvas.VIRTUAL_H -- all lines have scrolled off the top, restart from the bottom
		end
	end
end

-- returns the X position that horizontally centers 'text' on the virtual canvas
local function centerX(text)
	return (Canvas.VIRTUAL_W - font:getWidth(text)) / 2
end

local function drawMenuItem(text, x, y, isSelected)
	if isSelected then
		love.graphics.setColor(1, 1, 1, 1)

		local gap = 2 -- pixel gap between the arrow and the text edge
		local w = arrow:getWidth()

		love.graphics.draw(arrow, x - gap - w, y, 0, -1, 1) -- draw left arrow flipped horizontally
		love.graphics.draw(arrow, x + font:getWidth(text) + gap + w, y, 0, 1, 1) -- draw right arrow normally
	else
		love.graphics.setColor(0.45, 0.45, 0.45, 1) -- dim unselected items so the cursor stands out
	end

	love.graphics.print(text, x, y)
	love.graphics.setColor(1, 1, 1, 1) -- reset color so subsequent draws are not tinted
end

local function drawMain()
	local startY = 100 -- Y position of the first menu item
	local spacing = 36 -- vertical distance between each item

	love.graphics.setFont(font)

	for i, item in ipairs(mainItems) do
		local tx = centerX(item) -- center each label horizontally
		local ty = startY + (i - 1) * spacing -- stack items downward from startY
		drawMenuItem(item, tx, ty, UI.selected == i)
	end
end

local function drawOptions()
	local startY = 90
	local spacing = 36

	love.graphics.setFont(font)

	love.graphics.setColor(1, 0.55, 0, 1) -- orange for section titles
	love.graphics.print("OPTIONS", centerX("OPTIONS"), 60)
	love.graphics.setColor(1, 1, 1, 1)

	for i, item in ipairs(optionItems) do
		local label = item

		if item == "VIEW MODE" then
			label = "VIEW: " .. string.upper(UI.viewModes[UI.currentMode]) -- show current mode inline so player can see the value without selecting it
		end

		local tx = centerX(label)
		local ty = startY + (i - 1) * spacing
		drawMenuItem(label, tx, ty, UI.selected == i)
	end
end

local function drawCredits()
	love.graphics.setFont(font)

	love.graphics.setColor(1, 0.55, 0, 1)
	love.graphics.print("CREDITS", centerX("CREDITS"), 16)
	love.graphics.setColor(1, 1, 1, 1)

	local lineH = 18 -- height of each credit line in pixels

	for i, line in ipairs(UI.credits) do
		local y = creditScroll + (i - 1) * lineH -- offset each line by its index from the current scroll position

		if y > 30 and y < Canvas.VIRTUAL_H + lineH then -- skip drawing lines outside the visible canvas area
			if line ~= "" then -- skip spacer lines (empty strings act as blank rows)
				local isHeader = (line == line:upper() and not line:find("—")) -- all-caps lines with no em dash are category headers

				if isHeader then
					love.graphics.setColor(1, 0.55, 0, 1) -- orange for category headers
				else
					love.graphics.setColor(0.85, 0.85, 0.85, 1) -- light grey for regular credit entries
				end

				love.graphics.print(line, centerX(line), y)
			end
		end
	end

	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setColor(0.4, 0.4, 0.4, 1) -- dim hint text so it doesn't compete with the scrolling credits
	local hint = "PRESS BACK TO RETURN"
	love.graphics.print(hint, centerX(hint), Canvas.VIRTUAL_H - 20)
	love.graphics.setColor(1, 1, 1, 1)
end

local function drawPause()
	-- dark overlay on top of whatever the game drew underneath
	love.graphics.setColor(0, 0, 0, 0.6)
	love.graphics.rectangle("fill", 0, 0, Canvas.VIRTUAL_W, Canvas.VIRTUAL_H)
	love.graphics.setColor(1, 1, 1, 1)

	love.graphics.setFont(font)

	--title
	love.graphics.setColor(1, 0.55, 0, 1)
	love.graphics.print("PAUSED", centerX("PAUSED"), 60)
	love.graphics.setColor(1, 1, 1, 1)

	local startY = 100
	local spacing = 36

	for i, item in ipairs(pauseItems) do
		local tx = centerX(item)
		local ty = startY + (i + 1) * spacing
		drawMenuItem(item, tx, ty, UI.selected == i)
	end
end

function UI.drawCanvas(buffer, vw, vh)
	local winW, winH = love.graphics.getDimensions() -- actual window size in pixels
	local mode = UI.viewModes[UI.currentMode]
	local scale, ox, oy = 1, 0, 0

	if mode == "fit" then
		scale = math.min(winW / vw, winH / vh) -- largest scale that fits entirely inside the window
		ox = (winW - vw * scale) / 2 -- center horizontally
		oy = (winH - vh * scale) / 2 -- center vertically
		love.graphics.draw(buffer, ox, oy, 0, scale, scale)
	elseif mode == "fill" then
		scale = math.max(winW / vw, winH / vh) -- smallest scale that covers the entire window, cropping the excess
		ox = (winW - vw * scale) / 2
		oy = (winH - vh * scale) / 2
		love.graphics.setScissor(0, 0, winW, winH) -- clip so the cropped edges don't bleed outside the window
		love.graphics.draw(buffer, ox, oy, 0, scale, scale)
		love.graphics.setScissor() -- clear scissor so nothing else is accidentally clipped
	elseif mode == "stretch" then
		love.graphics.draw(buffer, 0, 0, 0, winW / vw, winH / vh) -- scale independently on each axis, ignoring aspect ratio
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
	end
end

-- returns true when the game world should be updated and drawn
function UI.isInGame()
	return UI.state == "game"
end

-- true when the game worlds should still be drawn (including while paused)
function UI.isPaused()
	return UI.state == "pause"
end

-- advances to the next view mode, used if you want a hotkey outside the options screen
function UI.cycleView()
	UI.currentMode = (UI.currentMode % #UI.viewModes) + 1
end

function UI.saveSettings()
	UISave.save({ currentMode = UI.currentMode }) -- serialize current settings into settings.json
end

function UI.loadSettings()
	local data = UISave.load() -- read and decode settings.json if it exists

	if data and data.currentMode then
		UI.currentMode = data.currentMode -- apply saved mode, leaving all other fields at their defaults if missing
	end
end

return UI

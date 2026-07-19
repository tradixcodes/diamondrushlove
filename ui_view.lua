local Canvas = require("canvas")
local DevTools = require("devtools")
local UIState = require("ui_state")

local UIView = {}

local font = nil
local arrow = nil

function UIView.load()
	font = love.graphics.newFont("font/BoldPixels.ttf", 24, "normal", 2)
	arrow = love.graphics.newImage("sprites_png/menu_arrow.png")
end

-- DRAW HELPERS

local function getSafe()
	local winW, winH = love.graphics.getDimensions()
	return Canvas.getSafeArea(winW, winH)
end

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

local function drawMenu(title, labels, selectedIndex)
	local safe = getSafe()
	local spacing = 36
	local totalH = #labels * spacing
	local startY = safe.centerY - totalH / 2

	love.graphics.setFont(font)

	if title then
		love.graphics.setColor(1, 0.55, 0, 1)
		love.graphics.print(title, centerX(title, safe), safe.top + 16)
		love.graphics.setColor(1, 1, 1, 1)
	end

	for i, label in ipairs(labels) do
		local tx = centerX(label, safe)
		local ty = startY + (i - 1) * spacing
		drawMenuItem(label, tx, ty, selectedIndex == i)
	end
end

-- SCREEN RENDERERS

local Canvas       = require("canvas")

local UI           = {}

-- ============================================================
-- CANVAS SETTINGS
-- ============================================================
UI.viewModes       = { "fit", "fill", "stretch" }
UI.currentMode     = 2

-- ============================================================
-- CREDITS — add new lines here freely, "" = spacer
-- ============================================================
UI.credits         = {
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

-- ============================================================
-- MENU STATE
-- ============================================================
UI.state           = "main" -- "main" | "options" | "credits" | "game"
UI.selected        = 1

local mainItems    = { "CONTINUE", "OPTIONS", "CREDITS", "EXIT" }
local optionItems  = { "VIEW MODE", "BACK" }

-- ============================================================
-- CREDITS SCROLL STATE
-- ============================================================
local creditScroll = 0
local creditSpeed  = 30 -- pixels per second

-- ============================================================
-- ASSETS  (swap paths to match your project structure)
-- ============================================================
local font         = nil
local arrow        = nil

function UI.load()
    UI.loadSettings()
    font = love.graphics.newFont("fonts/BoldPixels.ttf", 24)
    arrow = love.graphics.newImage("sprites_png/menu_arrow.png")
    love.graphics.setDefaultFilter("nearest", "nearest")
    creditScroll = Canvas.VIRTUAL_H
end

-- ============================================================
-- INPUT
-- ============================================================
function UI.keypressed(key)
    if UI.state == "main" then
        if key == "up" then
            UI.selected = math.max(1, UI.selected - 1)
        elseif key == "down" then
            UI.selected = math.min(#mainItems, UI.selected + 1)
        elseif key == "return" or key == "space" then
            local choice = mainItems[UI.selected]
            if choice == "CONTINUE" then
                UI.state = "game"
            elseif choice == "OPTIONS" then
                UI.state    = "options"
                UI.selected = 1
            elseif choice == "CREDITS" then
                UI.state     = "credits"
                creditScroll = Canvas.VIRTUAL_H -- reset scroll on entry
            elseif choice == "EXIT" then
                love.event.quit()
            end
        end
    elseif UI.state == "options" then
        if key == "up" then
            UI.selected = math.max(1, UI.selected - 1)
        elseif key == "down" then
            UI.selected = math.min(#optionItems, UI.selected + 1)
        elseif key == "return" or key == "space" or key == "left" or key == "right" then
            local choice = optionItems[UI.selected]
            if choice == "VIEW MODE" then
                if key == "left" then
                    UI.currentMode = (UI.currentMode - 2) % #UI.viewModes + 1
                else
                    UI.currentMode = (UI.currentMode % #UI.viewModes) + 1
                end
                UI.saveSettings()
            elseif choice == "BACK" then
                UI.state    = "main"
                UI.selected = 1
            end
        end
    elseif UI.state == "credits" then
        if key == "escape" or key == "return" or key == "backspace" then
            UI.state    = "main"
            UI.selected = 1
        end
    elseif UI.state == "game" then
        if key == "escape" then
            UI.state = "main"
            UI.selected = 1
        end
    end
end

-- ============================================================
-- UPDATE
-- ============================================================
function UI.update(dt)
    if UI.state == "credits" then
        local lineH  = 18
        local totalH = #UI.credits * lineH + Canvas.VIRTUAL_H
        creditScroll = creditScroll - (creditSpeed * dt)
        if creditScroll < - #UI.credits * lineH then
            creditScroll = Canvas.VIRTUAL_H -- loop back
        end
    end
end

-- ============================================================
-- DRAW HELPERS
-- ============================================================

local function centerX(text)
    return (Canvas.VIRTUAL_W - font:getWidth(text)) / 2
end

local function drawMenuItem(text, x, y, isSelected)
    if isSelected then
        love.graphics.setColor(1, 1, 1, 1)
        -- arrows: swap prints for image draws once you have the PNGs
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

-- ============================================================
-- DRAW SCREENS
-- ============================================================
local function drawMain()
    local startY  = 100
    local spacing = 36
    love.graphics.setFont(font)
    for i, item in ipairs(mainItems) do
        local tx = centerX(item)
        local ty = startY + (i - 1) * spacing
        drawMenuItem(item, tx, ty, UI.selected == i)
    end
end

local function drawOptions()
    local startY  = 90
    local spacing = 36
    love.graphics.setFont(font)

    -- title
    love.graphics.setColor(1, 0.55, 0, 1)
    love.graphics.print("OPTIONS", centerX("OPTIONS"), 60)
    love.graphics.setColor(1, 1, 1, 1)

    for i, item in ipairs(optionItems) do
        local tx    = centerX(item)
        local ty    = startY + (i - 1) * spacing
        local label = item
        if item == "VIEW MODE" then
            label = "VIEW: " .. string.upper(UI.viewModes[UI.currentMode])
        end
        tx = centerX(label)
        drawMenuItem(label, tx, ty, UI.selected == i)
    end
end

local function drawCredits()
    love.graphics.setFont(font)

    -- title
    love.graphics.setColor(1, 0.55, 0, 1)
    love.graphics.print("CREDITS", centerX("CREDITS"), 16)
    love.graphics.setColor(1, 1, 1, 1)

    -- scrolling lines
    local lineH = 18
    for i, line in ipairs(UI.credits) do
        local y = creditScroll + (i - 1) * lineH
        -- only draw if visible on canvas
        if y > 30 and y < Canvas.VIRTUAL_H + lineH then
            if line ~= "" then
                -- category headers in orange
                local isHeader = (line == line:upper() and not line:find("—"))
                if isHeader then
                    love.graphics.setColor(1, 0.55, 0, 1)
                else
                    love.graphics.setColor(0.85, 0.85, 0.85, 1)
                end
                love.graphics.print(line, centerX(line), y)
            end
        end
    end
    love.graphics.setColor(1, 1, 1, 1)

    -- back hint
    love.graphics.setColor(0.4, 0.4, 0.4, 1)
    local hint = "PRESS BACK TO RETURN"
    love.graphics.print(hint, centerX(hint), Canvas.VIRTUAL_H - 20)
    love.graphics.setColor(1, 1, 1, 1)
end

-- ============================================================
-- DRAW CANVAS (called from main.lua after canvas is set up)
-- ============================================================
function UI.drawCanvas(buffer, vw, vh)
    local winW, winH    = love.graphics.getDimensions()
    local mode          = UI.viewModes[UI.currentMode]
    local scale, ox, oy = 1, 0, 0

    if mode == "fit" then
        scale = math.min(winW / vw, winH / vh)
        ox    = (winW - vw * scale) / 2
        oy    = (winH - vh * scale) / 2
        love.graphics.draw(buffer, ox, oy, 0, scale, scale)
    elseif mode == "fill" then
        scale = math.max(winW / vw, winH / vh)
        ox    = (winW - vw * scale) / 2
        oy    = (winH - vh * scale) / 2
        love.graphics.setScissor(0, 0, winW, winH)
        love.graphics.draw(buffer, ox, oy, 0, scale, scale)
        love.graphics.setScissor()
    elseif mode == "stretch" then
        love.graphics.draw(buffer, 0, 0, 0, winW / vw, winH / vh)
    end
end

-- ============================================================
-- MAIN DRAW — call this inside your canvas render pass
-- ============================================================
function UI.draw()
    love.graphics.setFont(font)
    if UI.state == "main" then
        drawMain()
    elseif UI.state == "options" then
        drawOptions()
    elseif UI.state == "credits" then
        drawCredits()
    end
end

-- ============================================================
-- HELPERS
-- ============================================================
function UI.isInGame()
    return UI.state == "game"
end

function UI.cycleView()
    UI.currentMode = (UI.currentMode % #UI.viewModes) + 1
end

-- ============================================================
-- Save settings and load settings
-- ============================================================
function UI.saveSettings()
    local data = "currentMode=" .. UI.currentMode
    love.filesystem.write("settings.txt", data)
end

function UI.loadSettings()
    if love.filesystem.getInfo("settings.txt") then
        local data = love.filesystem.read("settings.txt")
        local mode = data:match("currentMode=(%d+)")
        if mode then
            UI.currentMode = tonumber(mode)
        end
    end
end

return UI

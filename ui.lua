local UI = {}

UI.viewModes = { "fit", "fill", "stretch" }
UI.currentMode = 1

function UI.cycleView()
    UI.currentMode = (UI.currentMode % #UI.viewModes) + 1
end

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

    -- label
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.print("View: " .. mode .. "(Tab to cycle)", 8, 8)
    love.graphics.setColor(1, 1, 1, 1)
end

return UI

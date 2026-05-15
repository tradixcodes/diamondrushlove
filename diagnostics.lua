local function draw()
    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1, 1, 1, 1)
    local fps = love.timer.getFPS()
    love.graphics.print("FPS: " .. fps, 10, 10)
    love.graphics.setColor(r, g, b, a)
end

return {
    draw = draw,
}

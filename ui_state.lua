local UISave = require("ui_save")
local DevTools = require("devtools")

local UIState = {}

UIState.viewModes = { "fit", "fill", "stretch" }
UIState.currentMode = 2

UIState.credits = {
    "FONTS", "BoldPixels — Yūki", "@YukiPixels", "",
    "MUSIC", "Track Name — Artist Name", "",
    "SFX", "Sound Name — Artist Name", "",
    "SPECIAL THANKS", "Someone — for something", "", ""
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
    if key == "return" or key == "space" or key == "left"
  end
end

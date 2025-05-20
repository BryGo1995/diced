local Menu = {}
Menu.__index = Menu

local Button = require("ui/button")

local buttons = {}
buttonWidth = 200
buttonHeight = 60

function Menu.new()
    local self = setmetatable({}, Menu)
    self.title = {
        text = "Diced",
        font = love.graphics.newFont(144),
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()/3
    }
    self.exit = false

    return self
end

function Menu:initializeButtons()
    -- Start Button
    buttons = {
        Button.new(
            "Start Game",
            love.graphics.getWidth()/2 - buttonWidth/2,
            love.graphics.getHeight()*0.6,
            buttonWidth,
            buttonHeight,
            {
                font = love.graphics.setNewFont(30),
                onClick = function()
                    print("Start Button clicked")
                    self.exit = true
                end
            } 
        )
    }
end

function Menu:init()
    self:initializeButtons()
end

function Menu:update(dt)
    for _, b in ipairs(buttons) do
        b:update(dt)
    end
end

function Menu:draw()
    -- Draw the title text TODO: put in its own function
    love.graphics.setFont(self.title.font)
    local xoffset = self.title.font:getWidth(self.title.text)/2
    local yoffset = self.title.font:getHeight(self.title.text)/2
    love.graphics.print(self.title.text, self.title.x - xoffset, self.title.y - yoffset)

    for _, b in ipairs(buttons) do
        b:draw()
    end
end

function Menu:onClick(x, y)
    for _, b in ipairs(buttons) do
        if b:isPointInside(x, y) then
            b:onClick()
        end
    end
end

function Menu:exitStatus()
    return self.exit
end

return Menu
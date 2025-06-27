local Menu = {}
Menu.__index = Menu

local Button = require("src/ui/button")
local sprites = require("src/ui/sprites")
local fonts = require("src/ui/fonts")

local buttons = {}
local buttonWidth = 300
local buttonHeight = 70

function Menu.new()
    local self = setmetatable({}, Menu)
    self.title = {
        text = "Diced",
        font = love.graphics.newFont(144),
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()*0.6,
        sprite = sprites.title,
        scale = 3.6
    }
    self.exit = false

    return self
end

function Menu:initializeButtons()
    -- Start Button
    buttons = {
        Button.new(
            "START",
            love.graphics.getWidth()/2 - buttonWidth/2,
            love.graphics.getHeight()*0.8,
            buttonWidth,
            buttonHeight,
            {
                backgroundColor = {love.math.colorFromBytes(43, 184, 177)},
                font = fonts.default,
                textScaler = 7,
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
    local r, g, b = love.math.colorFromBytes(107, 155, 115)
    love.graphics.setBackgroundColor(r, g, b)
    local xoffset = self.title.sprite:getWidth()/2 * self.title.scale
    local yoffset = self.title.sprite:getHeight()/2 * self.title.scale
    love.graphics.draw(self.title.sprite, self.title.x - xoffset, self.title.y - yoffset, 0, self.title.scale, self.title.scale)

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

function Menu:getExitStatus()
    return self.exit
end

function Menu:resetExitStatus()
    self.exit = false
end

return Menu
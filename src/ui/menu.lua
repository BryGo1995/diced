local Menu = {}
Menu.__index = Menu

local Button = require("src/ui/button")
local sprites = require("src/ui/sprites")

local buttons = {}
local buttonWidth = 200
local buttonHeight = 60

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
            "Start Game",
            love.graphics.getWidth()/2 - buttonWidth/2,
            love.graphics.getHeight()*0.8,
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
    local r, g, b = love.math.colorFromBytes(107, 155, 115)
    love.graphics.setBackgroundColor(r, g, b)
    local xoffset = self.title.sprite:getWidth()/2 * self.title.scale
    local yoffset = self.title.sprite:getHeight()/2 * self.title.scale
    self.title.sprite:setFilter("nearest", "nearest")
    love.graphics.draw(self.title.sprite, self.title.x - xoffset, self.title.y - yoffset, 0, self.title.scale, self.title.scale)

    for _, b in ipairs(buttons) do
        --b:draw()
    end

    local font = love.graphics.newImageFont("assets/fonts/demo-font.png",
        " abcdefghijklmnopqrstuvwxyz" ..
        "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
        "123456789.,!?-+/():;%&`'*#=[]\"")

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.graphics.setFont(font)
    love.graphics.print("START", 100, 100, 0, 4, 4)

    love.graphics.draw(sprites.startButton, love.graphics.getWidth()/2 - sprites.startButton:getWidth()/2, love.graphics.getHeight()*0.8)
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
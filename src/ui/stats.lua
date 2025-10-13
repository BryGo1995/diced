local Stats = {}
Stats.__index = Stats

local Sprites = require("src/ui/sprites")
local Button = require("src/ui/button")

function Stats.new()
    local self = setmetatable({}, Stats)

    -- Initialize with default values, will be updated later
    self.window = {
        sprite = Sprites.statsWindowHanging,
        scale = 3.6,
        x = 100,
        y = 100,
        width = 400,
        height = 300
    }
    self.exitIcon = {
        sprite = Sprites.exitIconSprite,
        scale = 3.6,
        x = 100,
        y = 100,
        color = {1, 1, 1},
        hoveredColor = {0.5, 0.5, 0.5}
    }
    self.buttons = {}

    return self
end

function Stats:init()
    -- Update dimensions based on current screen size
    self.window.width = love.graphics.getWidth()*0.5
    self.window.height = love.graphics.getHeight()*0.5
    self.window.x = love.graphics.getWidth()/2 - self.window.sprite:getWidth()*self.window.scale/2
    self.window.y = love.graphics.getHeight()/2 - self.window.sprite:getHeight()*self.window.scale/2

    self.exitIcon.x = self.window.x + self.window.width + 20
    self.exitIcon.y = self.window.y + 225

    self.text = {
        x = self.window.x + 50,
        y = self.window.y + 225,
        scale = 3
    }

    self:initializeButtons()
end

function Stats:update()

end

function Stats:onClick(x, y)
    for _, b in ipairs(self.buttons) do
        if b:isPointInside(x, y) then
            b:onClick()
        end
    end
end

function Stats:displayStats()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.draw(self.window.sprite, self.window.x, self.window.y, 0, self.window.scale, self.window.scale)
    love.graphics.setColor(0.5, 0.5, 0.5)
    for _, b in ipairs(self.buttons) do
        b:draw()
    end
    love.graphics.setColor(1, 1, 1)
end

function Stats:initializeButtons()
    self.buttons = {
        Button.new(
            self.window.x + self.window.width + 48,
            self.window.y + 250,
            {
                text = "",
                sprite = Sprites.exitIconSprite,
                spriteScaler = 3.6,
                onClick = function()
                    print("Exit button clicked")
                end
            }
        )
    }
end

return Stats
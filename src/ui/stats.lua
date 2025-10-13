local Stats = {}
Stats.__index = Stats

local sprites = require("src/ui/sprites")

function Stats.new()
    local self = setmetatable({}, Stats)

    -- Initialize with default values, will be updated later
    self.window = {
        sprite = sprites.statsWindowHanging,
        scale = 3.6,
        x = 100,
        y = 100,
        width = 400,
        height = 300
    }
    self.exitIcon = {
        sprite = sprites.exitIconSprite,
        scale = 3.6,
        x = 100,
        y = 100,
        color = {1, 1, 1},
        hoveredColor = {0.5, 0.5, 0.5}
    }

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
end

function Stats:displayStats()
    love.graphics.setBackgroundColor(0, 0, 0)
    love.graphics.draw(self.window.sprite, self.window.x, self.window.y, 0, self.window.scale, self.window.scale)
    love.graphics.setColor(0.5, 0.5, 0.5)
    love.graphics.draw(self.exitIcon.sprite, self.exitIcon.x, self.exitIcon.y, 0, self.exitIcon.scale, self.exitIcon.scale)
    love.graphics.setColor(1, 1, 1)
end

return Stats
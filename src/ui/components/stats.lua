local Stats = {}
Stats.__index = Stats

local Sprites = require("src/ui/sprites")
local Button = require("src/ui/button")
local Fonts = require("src/ui/fonts")
local SaveManager = require("src/save_manager")

function Stats.new()
    local self = setmetatable({}, Stats)

    self.active = false
    self.window = {
        sprite = Sprites.statsWindowHanging,
        scale = 3.6,
        x = 100,
        y = 100,
        width = 400,
        height = 300,
    }
    self.buttons = {}
    self.bestScore = nil

    return self
end

function Stats:init()
    self.saveManager = SaveManager.new()

    self.window.width = self.window.sprite:getWidth()*self.window.scale
    self.window.height = self.window.sprite:getHeight()*self.window.scale
    self.window.x = love.graphics.getWidth()/2 - self.window.width/2
    self.window.y = love.graphics.getHeight()/2 - self.window.height/2

    self.text = {
        x = self.window.x + 50,
        y = self.window.y + 225,
        scale = 3,
        font = fonts.default
    }

    self:initializeButtons()
end

function Stats:update()
    for _, b in ipairs(self.buttons) do
        b:update(dt)
    end
end

function Stats:draw()
    self:displayStats()
end

function Stats:onClick(x, y)
    if self.active == true then
        for _, b in ipairs(self.buttons) do
            if b:isPointInside(x, y) then
                b:onClick()
            end
        end
    end
end

function Stats:loadStats()
    local saveData, error = self.saveManager:loadData()
    local lowScore
    if not saveData or not saveData.lowScore then
        lowScore = "GET TO PLAYING!"
    else
        lowScore = tostring(saveData.lowScore)
    end

    self.bestScore = lowScore
end

function Stats:displayStats()
    if self.active then
        self:loadStats()

        love.graphics.setBackgroundColor(0, 0, 0)
        love.graphics.draw(self.window.sprite, self.window.x, self.window.y, 0, self.window.scale, self.window.scale)

        love.graphics.setColor(0.5, 0.5, 0.5)
        for _, b in ipairs(self.buttons) do
            b:draw()
        end
        love.graphics.setColor(1, 1, 1)

        love.graphics.setFont(self.text.font)
        if self.bestScore == nil then
            love.graphics.print("GET TO PLAYING!", self.text.x, self.text.y, 0, self.text.scale, self.text.scale)
        else
            love.graphics.print("BEST RUN: "..self.bestScore, self.text.x, self.text.y, 0, self.text.scale, self.text.scale)
        end
    end
end

function Stats:initializeButtons()
    self.buttons = {
        Button.new(
            self.window.x + self.window.width - 70,
            self.window.y + 250,
            {
                text = "",
                sprite = Sprites.exitIconSprite,
                hoveredSprite = Sprites.exitIconSpriteHovered,
                spriteScaler = 3.6,
                onClick = function()
                    print("Exit button clicked")
                    self.active = false
                end
            }
        )
    }
end

return Stats
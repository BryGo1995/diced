local Menu = {}
Menu.__index = Menu

local Stats = require("src/ui/stats")
local Button = require("src/ui/button")
local sprites = require("src/ui/sprites")
local fonts = require("src/ui/fonts")

local buttons = {}
local globalScaler = 3.6
--local statsModule = Stats.new()

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
    self.statsModule = Stats.new()
    self.displayStats = false
    self.exit = false

    return self
end

function Menu:initializeButtons()
    -- Start Button
    buttons = {
        Button.new(
            love.graphics.getWidth()/2,
            love.graphics.getHeight()*0.75,
            {
                text = "START",
                sprite = sprites.basicButton,
                spriteScaler = globalScaler,
                backgroundColor = {love.math.colorFromBytes(43, 184, 177)},
                borderColor = {0, 0, 0},
                borderWidth = 3,
                font = fonts.default,
                textScaler = 7,
                onClick = function()
                    print("Start Button clicked")
                    self.exit = true
                end
            } 
        ),
        Button.new(
            love.graphics.getWidth()/2,
            love.graphics.getHeight()*0.9,
            {
                text = "STATS",
                sprite = sprites.basicButton,
                spriteScaler = globalScaler,
                backgroundColor = {love.math.colorFromBytes(43, 184, 177)},
                borderColor = {0, 0, 0},
                borderWidth = 3,
                font = fonts.default,
                textScaler = 7,
                onClick = function()
                    print("Stats Button Clicked")
                    self.displayStats = not self.displayStats
                end
            }
        )
    }
end

function Menu:init()
    self:initializeButtons()
    self.statsModule:init()
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

    if self.displayStats then
        self:displayGameStats()
    end

end

function Menu:onClick(x, y)
    if self.displayStats == false then
        for _, b in ipairs(buttons) do
            if b:isPointInside(x, y) then
                b:onClick()
            end
        end
    else
        self.statsModule:onClick(x, y)
    end
end

function Menu:displayGameStats()
    local SaveManager = require("src/save_manager")
    local saveManager = SaveManager.new()
    
    local saveData, error = saveManager:loadData()
    local lowScore
    if not saveData or not saveData.lowScore then
        lowScore = "GET TO PLAYING!"
    else
        lowScore = tostring(saveData.lowScore)
    end

    self.statsModule:displayStats()

    love.graphics.setColor(0.0, 0.5, 0.5)
    love.graphics.setFont(fonts.default)
    love.graphics.print("BEST RUN: " .. lowScore, self.statsModule.text.x, self.statsModule.text.y, 0, self.statsModule.text.scale, self.statsModule.text.scale)
    love.graphics.setColor(1, 1, 1)
end

function Menu:getExitStatus()
    return self.exit
end

function Menu:resetExitStatus()
    self.exit = false
end

return Menu
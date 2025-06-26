local Dice = {}
Dice.__index = Dice

local sprites = require("src/ui/sprites")
local fonts = require("src/ui/fonts")

function Dice.new(numOfSides)
    local self = setmetatable({}, Dice)
    self.numOfSides = numOfSides
    self.x = 0
    self.y = 0
    self.scale = 3
    self.active = true
    self.selected = false
    self.currentValue = 0
    self.sprite = {
        key = "d6_blank",
        width = 0,
        height = 0
    }
    self.hitbox = {
        x = 0,
        y = 0,
        width = 0,
        height = 0,
        lineWidth = 3,
        lineColor = "white"
    }

    return self
end

function Dice:init(position)
    self.x = position.x
    self.y = position.y
    self.active = true
    self.selected = false
    self.currentValue = 0
end

function Dice:update(dt, position)
    self.sprite.key = "d"..self.numOfSides.."_blank"
    self.sprite.width = sprites[self.sprite.key]:getWidth()
    self.sprite.height = sprites[self.sprite.key]:getHeight()

    self.hitbox.width = self.sprite.width * self.scale
    self.hitbox.height = self.sprite.height * self.scale
    self.hitbox.x = self.x - self.hitbox.width/2
    self.hitbox.y = self.y - self.hitbox.height/2
end

function Dice:draw()
    love.graphics.draw(sprites[self.sprite.key], 
                       self.x,
                       self.y,
                       0,
                       self.scale,
                       self.scale,
                       self.sprite.width/2,
                       self.sprite.height/2
                       )
    
    love.graphics.setFont(fonts.diceDefault)
    love.graphics.print(self.currentValue, 
                        self.x, 
                        self.y, 
                        0, 
                        self.scale, 
                        self.scale,
                        fonts.diceDefault:getWidth(self.currentValue)/2,
                        fonts.diceDefault:getHeight(self.currentValue)/2)

    love.graphics.setLineWidth(self.hitbox.lineWidth)
    if self.selected and self.active then
        love.graphics.rectangle("line",
                                self.hitbox.x,
                                self.hitbox.y,
                                self.hitbox.width,
                                self.hitbox.height
                                )
    end
end

function Dice:roll()
    if self.active then
        self.currentValue = self:randomNumber(self.numOfSides)
    end
end

function Dice:setPosition(position)
    self.x = position.x
    self.y = position.y
end

function Dice:randomNumber(numOfSides)
    return love.math.random(1, numOfSides)
end

function Dice:onClick(x, y)
    if self:aabbCollision(x, y) and self.active then
        self.selected = not self.selected
    end
end

function Dice:aabbCollision(mx, my)
    if mx > self.hitbox.x and mx < self.hitbox.x + self.hitbox.width and
       my > self.hitbox.y and my < self.hitbox.y + self.hitbox.height then
            return true
    end
    return false
end

function Dice:calculateScore()
    local calculatedScore = 0
    if self.active then
        self.active = false
        self.selected = false
        calculatedScore = self.numOfSides - self.currentValue
        self.currentValue = "blank"
    end
    return calculatedScore
end

return Dice
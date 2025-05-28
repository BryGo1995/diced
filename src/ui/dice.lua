local Dice = {}
Dice.__index = Dice

local sprites = require("src/ui/sprites")

function Dice.new(numOfSides)
    local self = setmetatable({}, Dice)
    self.numOfSides = numOfSides
    self.x = 0
    self.y = 0
    self.spriteKey = "d6_blank"
    
    self.active = true
    self.selected = false
    self.currentValue = 0

    self.hitbox = {
        x = 0,
        y = 0,
    }

    return self
end

function Dice:init(position)
    self.x = position.x
    self.y = position.y
end

function Dice:update(dt)
    self.spriteKey = "d"..self.numOfSides.."_"..self.currentValue
    self.hitbox.width = sprites[self.spriteKey]:getWidth()
    self.hitbox.height = sprites[self.spriteKey]:getHeight()
end

function Dice:draw()
    love.graphics.draw(sprites[self.spriteKey], self.x, self.y)
    if self.selected and self.active then
        love.graphics.rectangle("line", self.x, self.y, self.hitbox.width, self.hitbox.height)
    end
end

function Dice:roll()
    if self.active then
        self.currentValue = self:randomNumber(self.numOfSides)
    end
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
    if mx > self.x and mx < self.x + self.hitbox.width and
       my > self.y and my < self.y + self.hitbox.height then
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
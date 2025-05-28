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
        width = 0,
        height = 0
    }

    return self
end

function Dice:init(position)
    self.x = position.x
    self.y = position.y

end

function Dice:update(dt)
    self.spriteKey = "d"..self.numOfSides.."_"..self.currentValue
end

function Dice:draw()
    love.graphics.draw(sprites[self.spriteKey], self.x, self.y)
end

function Dice:roll()
    self.currentValue = self:randomNumber(self.numOfSides)
end

function Dice:randomNumber(numOfSides)
    return love.math.random(1, numOfSides)
end

return Dice
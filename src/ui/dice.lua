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
    if self.selected then
        love.graphics.rectangle("line", self.x, self.y, self.hitbox.width, self.hitbox.height)
    end
end

function Dice:roll()
    self.currentValue = self:randomNumber(self.numOfSides)
end

function Dice:randomNumber(numOfSides)
    return love.math.random(1, numOfSides)
end

function Dice:onClick(x, y)
    if self:aabbCollision(x, y) then
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

return Dice
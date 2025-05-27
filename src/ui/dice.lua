local Dice = {}
Dice.__index = Dice

local sprites = require("src/ui/sprites")

function Dice.new(numOfSides)
    local self = setmetatable({}, Dice)
    self.numOfSides = numOfSides
    self.x = 0
    self.y = 0
    
    self.active = true
    self.selected = false
    self.currentValue = 0

    return self
end

function Dice:init(position)
    self.x = position.x
    self.y = position.y
end

function Dice:update(dt)

end

function Dice:draw()
    love.graphics.draw(sprites.d6_1, self.x, self.y)
end

return Dice
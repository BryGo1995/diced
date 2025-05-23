local GameLoop = {}
GameLoop.__index = GameLoop

local Dice = require("src/ui/dice")

function GameLoop.new()
    local self = setmetatable({}, GameLoop)
    self.score = 0

    return self
end

function GameLoop:init()
    dice = Dice.new(6)
    dice:init()
end

function GameLoop:update(dt)

end

function GameLoop:draw()
    dice:draw()
end

return GameLoop
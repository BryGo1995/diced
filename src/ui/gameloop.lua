local GameLoop = {}
GameLoop.__index = GameLoop

local Dice = require("src/ui/dice")

gameWindow = {height = 800, width = 1400}
verticalCells = 5

function GameLoop.new(numOfDice)
    local self = setmetatable({}, GameLoop)
    self.score = 0
    self.dice = {}
    self.numOfDice = numOfDice

    return self
end

function GameLoop:init()
    local pos = setDicePositions(self.numOfDice)
    for i = 1, self.numOfDice do
        self.dice[i] = Dice.new(6)
        self.dice[i]:init(pos[i])        
    end
end

function GameLoop:update(dt)

end

function GameLoop:draw()
    for i = 1, self.numOfDice do
        self.dice[i]:draw()
    end
end

function setDicePositions(numOfDice)
    local dicePositions = {}
    local xoffset = gameWindow.width/verticalCells/2
    local yoffset = gameWindow.height/verticalCells/2
    for i = 1, numOfDice do
        local position = {
            x = xoffset + ((i-1)%verticalCells) * (gameWindow.width/verticalCells),
            y = yoffset + math.floor((i-1)/verticalCells) * (gameWindow.height/verticalCells)
        }
        table.insert(dicePositions, position)
    end
    return dicePositions
end

return GameLoop
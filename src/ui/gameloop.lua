local GameLoop = {}
GameLoop.__index = GameLoop

local Dice = require("src/ui/dice")
local Button = require("src/ui/button")

gameWindow = {height = 800, width = 1400}
verticalCells = 5

local buttons = {}
local buttonWidth = 200
local buttonHeight = 60

function GameLoop.new(numOfDice)
    local self = setmetatable({}, GameLoop)
    self.score = 0
    self.dice = {}
    self.numOfDice = numOfDice

    return self
end

function GameLoop:initializeButtons()
    buttons = {
        Button.new(
            "Roll Dice",
            love.graphics.getWidth()/2 - buttonWidth/2,
            love.graphics.getHeight()*0.9,
            buttonWidth,
            buttonHeight,
            {
                font = love.graphics.setNewFont(30),
                onClick = function()
                    for _, d in ipairs(self.dice) do
                        d:roll()
                    end 
                end
            }
        )
    }
end

function GameLoop:init()
    local pos = setDicePositions(self.numOfDice)
    for i = 1, self.numOfDice do
        self.dice[i] = Dice.new(6)
        self.dice[i]:init(pos[i])        
        self.dice[i]:roll()
    end

    self:initializeButtons()
end

function GameLoop:update(dt)
    for _, b in ipairs(buttons) do
        b:update()
    end
end

function GameLoop:draw()
    for i = 1, self.numOfDice do
        self.dice[i]:draw()
    end

    for _, b in ipairs(buttons) do
        b:draw()
    end
end

function GameLoop:onClick(x, y)
    for _, b in ipairs(buttons) do
        if b:isPointInside(x, y) then
            b:onClick()
        end
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
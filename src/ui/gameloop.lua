local GameLoop = {}
GameLoop.__index = GameLoop

local Dice = require("src/ui/dice")
local Button = require("src/ui/button")

gameWindow = {height = 800, width = 1400}
verticalCells = 5
horizontalCells = 4

local buttons = {}
local buttonWidth = 200
local buttonHeight = 60

function GameLoop.new(numOfSixSidedDice, numOfEightSidedDice, numOfTenSideDice)
    local self = setmetatable({}, GameLoop)
    self.score = 0
    self.dice = {}
    self.numOfSixSidedDice = numOfSixSidedDice
    self.numOfEightSidedDice = numOfEightSidedDice
    self.numOfTenSideDice = numOfTenSideDice
    self.numOfDice = numOfSixSidedDice + numOfEightSidedDice + numOfTenSideDice

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
                        if d.selected then
                            self.score = self.score + d:calculateScore()
                        else
                            d:roll()
                        end
                    end 
                end
            }
        )
    }
end

function GameLoop:init()
    self.score = 0

    local pos = setDicePositions(self.numOfDice)
    local index = 1
    for index = 1, self.numOfSixSidedDice do
        self.dice[index] = Dice.new(6)
        self.dice[index]:init(pos[index])        
        self.dice[index]:roll()
    end

    for index = self.numOfSixSidedDice + 1, self.numOfSixSidedDice + self.numOfEightSidedDice do
        self.dice[index] = Dice.new(8)
        self.dice[index]:init(pos[index])        
        self.dice[index]:roll()
    end

    for index = self.numOfSixSidedDice + self.numOfEightSidedDice + 1, self.numOfDice do
        self.dice[index] = Dice.new(10)
        self.dice[index]:init(pos[index])        
        self.dice[index]:roll()
    end
    
    self:initializeButtons()
end

function GameLoop:update(dt)
    for i = 1, self.numOfDice do
        self.dice[i]:update(dt)
    end

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

    love.graphics.print("Current score: "..self.score, 100, 850)
end

function GameLoop:isButtonActive()
    for i = 1, self.numOfDice do
        if self.dice[i].selected then
            return true 
        end
    end
end

function GameLoop:onClick(x, y)
    for i = 1, self.numOfDice do
        self.dice[i]:onClick(x, y)
    end

    if self:isButtonActive() then
        for _, b in ipairs(buttons) do
            if b:isPointInside(x, y) then
                b:onClick()
            end
        end 
    end
end

function GameLoop:isGameOver()
    local gameOver = true
    for i = 1, self.numOfDice do
        if self.dice[i].active then
            gameOver = false
        end
    end
    return gameOver
end

function setDicePositions(numOfDice)
    local dicePositions = {}
    local xoffset = gameWindow.width/verticalCells/2
    local yoffset = gameWindow.height/horizontalCells/2
    for i = 1, numOfDice do
        local position = {
            x = xoffset + ((i-1)%verticalCells) * (gameWindow.width/verticalCells),
            y = yoffset + math.floor((i-1)/verticalCells) * (gameWindow.height/horizontalCells)
        }
        table.insert(dicePositions, position)
    end
    return dicePositions
end

return GameLoop
local GameLoop = {}
GameLoop.__index = GameLoop

local Dice = require("src/ui/dice")
local Button = require("src/ui/button")
local fonts = require("src/ui/fonts")

gameWindow = {height = 800, width = 1400}
verticalCells = 5
horizontalCells = 4

local buttons = {}
local buttonWidth = 200
local buttonHeight = 60

function GameLoop.new(numOfSixSidedDice, numOfEightSidedDice, numOfTenSidedDice, numOfTwelveSidedDice, numOfTwentySidedDice)
    local self = setmetatable({}, GameLoop)
    self.score = 0
    self.scoreScale = 5
    self.anyDiceSelected = false
    self.projectedScore = 0
    self.dice = {}
    self.numOfSixSidedDice = numOfSixSidedDice
    self.numOfEightSidedDice = numOfEightSidedDice
    self.numOfTenSidedDice = numOfTenSidedDice
    self.numOfTwelveSidedDice = numOfTwelveSidedDice
    self.numOfTwentySidedDice = numOfTwentySidedDice
    self.numOfDice = numOfSixSidedDice + numOfEightSidedDice + numOfTenSidedDice + numOfTwelveSidedDice + numOfTwentySidedDice

    return self
end

function GameLoop:initializeButtons()
    buttons = {
        Button.new(
            love.graphics.getWidth()/2,
            love.graphics.getHeight()*0.935,
            {
                text = "ROLL",
                width = buttonWidth,
                height = buttonHeight,
                backgroundColor = {love.math.colorFromBytes(43, 184, 177)},
                borderColor = {0, 0, 0},
                borderWidth = 3,
                font = fonts.default,
                textScaler = 5,
                onClick = function()
                    local pos = setDicePositions(self.numOfDice)
                    local randomDicePositions = self:randomizeDicePositions()
                    for i = 1, self.numOfDice do
                        if self.dice[i].selected then
                            self.score = self.score + self.dice[i]:calculateScore()
                        else
                            self.dice[i]:roll()
                        end
                        self.dice[i]:setPosition(pos[randomDicePositions[i]])
                    end 
                end
            }
        )
    }
end

function GameLoop:init()
    self.score = 0

    local pos = setDicePositions(self.numOfDice)
    local randomDicePositions = self:randomizeDicePositions()
    local index = 1
    for index = 1, self.numOfSixSidedDice do
        self.dice[index] = Dice.new(6, {font = fonts.diceDots})
        self.dice[index]:init(pos[randomDicePositions[index]])        
        self.dice[index]:roll()
    end

    for index = self.numOfSixSidedDice + 1, self.numOfSixSidedDice + self.numOfEightSidedDice do
        self.dice[index] = Dice.new(8)
        self.dice[index]:init(pos[randomDicePositions[index]])        
        self.dice[index]:roll()
    end

    for index = self.numOfSixSidedDice + self.numOfEightSidedDice + 1, self.numOfDice do
        self.dice[index] = Dice.new(10)
        self.dice[index]:init(pos[randomDicePositions[index]])        
        self.dice[index]:roll()
    end

    for index = self.numOfSixSidedDice + self.numOfEightSidedDice + self.numOfTenSidedDice + 1, self.numOfDice do
        self.dice[index] = Dice.new(12)
        self.dice[index]:init(pos[randomDicePositions[index]])
        self.dice[index]:roll()
    end

    for index = self.numOfSixSidedDice + self.numOfEightSidedDice + self.numOfTenSidedDice + self.numOfTwelveSidedDice + 1, self.numOfDice do
        self.dice[index] = Dice.new(20)
        self.dice[index]:init(pos[randomDicePositions[index]])
        self.dice[index]:roll()
    end
    
    self:initializeButtons()
end

function GameLoop:update(dt)
    self.anyDiceSelected = false
    local cumulativeScore = 0
    for i = 1, self.numOfDice do
        self.dice[i]:update(dt)
        if self.dice[i].selected then
            cumulativeScore = cumulativeScore + self.dice[i]:peekScore()
            self.anyDiceSelected = true
        end
    end
    self.projectedScore = cumulativeScore
    
    for _, b in ipairs(buttons) do
        b:update()
    end
end

function GameLoop:draw()
    for i = 1, self.numOfDice do
        if self.dice[i].active then
            self.dice[i]:draw()
        end
    end

    for _, b in ipairs(buttons) do
        b:draw()
    end

    love.graphics.setFont(fonts.default)
    local textX = 20
    local textY = love.graphics.getHeight()*0.91
    local scoreDisplay = "SCORE: "..self.score
    love.graphics.print(scoreDisplay, textX, textY, 0, self.scoreScale, self.scoreScale)

    local textX2 = fonts.default:getWidth(scoreDisplay)*self.scoreScale
    if self.anyDiceSelected and self.projectedScore > 0 then
        love.graphics.print("+"..self.projectedScore, textX + textX2, textY, 0, self.scoreScale, self.scoreScale)
    end
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

function GameLoop:randomizeDicePositions()
    local dicePositions = {}
    for i = 1, self.numOfDice do
        dicePositions[i] = i
    end

    math.randomseed(os.time())
    for i = 1, self.numOfDice do
        local randomIndex = math.random(1, #dicePositions)
        local temp = dicePositions[i]
        dicePositions[i] = dicePositions[randomIndex]
        dicePositions[randomIndex] = temp
    end

    return dicePositions
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
local GameLoop = {}
GameLoop.__index = GameLoop

local Dice = require("src/core/dice")
local Button = require("src/ui/components/button")
local Sprites = require("src/ui/assets/sprites")
local fonts = require("src/ui/assets/fonts")

local gameWindow = {height = 800, width = 1000}
local verticalCells = 5
local horizontalCells = 4

local windowCenter = {
    x = love.graphics.getWidth()/2,
    y = love.graphics.getHeight()/2
}

local buttons = {}
local exitMenuButtons = {}
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

    self.displayExitMenu = false
    self.returnToMenu = false
    self.exitWindow = {
        sprite = Sprites.statsWindow,
        scale = 3,
        x = 0,
        y = 0,
        text = {
            message = "EXIT GAME?",
            font = fonts.default,
            x = windowCenter.x,
            y = windowCenter.y,
            scale = 7
        },
        warning = {
            message = "PROGRESS WILL BE LOST",
            font = fonts.default,
            x = windowCenter.x,
            y = windowCenter.y,
            scale = 3
        }
    }

    return self
end

function GameLoop:initializeButtons()
    buttons = {
        Button.new(
            love.graphics.getWidth()/2,
            love.graphics.getHeight()*0.935,
            {
                text = "ROLL",
                active = false,
                sprite = Sprites.basicButtonShort,
                spriteScaler = 3.6,
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
        ),
        Button.new(
            love.graphics.getWidth() - 50,
            50,
            {
                text = "",
                sprite = Sprites.exitIconSprite,
                hoveredSprite = Sprites.exitIconSpriteHovered,
                spriteScaler = 3.6,
                onClick = function()
                    print("Exit Button clicked")
                    self.displayExitMenu = true
                end
            }
        )
    }

    exitMenuButtons = {
        Button.new(
            windowCenter.x - 125,
            windowCenter.y + 100,
            {
                text = "YES",
                sprite = Sprites.basicButtonShort,
                spriteScaler = 3.6,
                font = fonts.default,
                textScaler = 5,
                onClick = function()
                    print("YES")
                    self.returnToMenu = true
                end
            }
        ),
        Button.new(
            windowCenter.x + 125,
            windowCenter.y + 100,
            {
                text = "NO",
                sprite = Sprites.basicButtonShort,
                spriteScaler = 3.6,
                font = fonts.default,
                textScaler = 5,
                onClick = function()
                    print("NO")
                    self.displayExitMenu = false
                end
            }
        )
    }
end

function GameLoop:init()
    self.returnToMenu = false
    self.displayExitMenu = false
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

    self.exitWindow.x = windowCenter.x - self.exitWindow.sprite:getWidth()*self.exitWindow.scale/2
    self.exitWindow.y = windowCenter.y - self.exitWindow.sprite:getHeight()*self.exitWindow.scale/2
    self.exitWindow.text.x = windowCenter.x - self.exitWindow.text.font:getWidth(self.exitWindow.text.message)*self.exitWindow.text.scale/2
    self.exitWindow.text.y = windowCenter.y - self.exitWindow.text.font:getHeight(self.exitWindow.text.message)*self.exitWindow.text.scale/2 - 70
    self.exitWindow.warning.x = windowCenter.x - self.exitWindow.warning.font:getWidth(self.exitWindow.warning.message)*self.exitWindow.warning.scale/2
    self.exitWindow.warning.y = windowCenter.y - self.exitWindow.warning.font:getHeight(self.exitWindow.warning.message)*self.exitWindow.warning.scale/2 + 10

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
    
    if self.displayExitMenu then
        for _, b in ipairs(exitMenuButtons) do
            b:update()
        end
    else
        for _, b in ipairs(buttons) do
            self:isRollButtonActive()
            b:update()
        end
    end
end

function GameLoop:draw()
    if self.displayExitMenu then
        self:drawExitMenu()
    else
        self:drawGameScreen()
    end
end

function GameLoop:drawGameScreen()
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

function GameLoop:drawExitMenu()
    love.graphics.draw(
        self.exitWindow.sprite,
        self.exitWindow.x,
        self.exitWindow.y,
        0,
        self.exitWindow.scale,
        self.exitWindow.scale
    )

    love.graphics.setFont(self.exitWindow.text.font)
    love.graphics.print(
        self.exitWindow.text.message,
        self.exitWindow.text.x,
        self.exitWindow.text.y,
        0,
        self.exitWindow.text.scale,
        self.exitWindow.text.scale
    )

    love.graphics.setFont(self.exitWindow.warning.font)
    love.graphics.print(
        self.exitWindow.warning.message,
        self.exitWindow.warning.x,
        self.exitWindow.warning.y,
        0,
        self.exitWindow.warning.scale,
        self.exitWindow.warning.scale
    )

    for _, b in ipairs(exitMenuButtons) do
        b:draw()
    end
end

function GameLoop:isRollButtonActive()
    buttons[1].active = false
    for i = 1, self.numOfDice do
        if self.dice[i].selected then
            buttons[1].active = true
        end
    end
end

function GameLoop:onClick(x, y)

    if self.displayExitMenu then
        for _, b in ipairs(exitMenuButtons) do
            if b.active and b:isPointInside(x, y) then
                b:onClick()
            end
        end
    else
        for i = 1, self.numOfDice do
            self.dice[i]:onClick(x, y)
        end

        self:isRollButtonActive()
        for _, b in ipairs(buttons) do
            if b.active and b:isPointInside(x, y) then
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
    local xPadding = (love.graphics.getWidth() - gameWindow.width)/2
    for i = 1, numOfDice do
        local position = {
            x = xPadding + xoffset + ((i-1)%verticalCells) * (gameWindow.width/verticalCells),
            y = yoffset + math.floor((i-1)/verticalCells) * (gameWindow.height/horizontalCells)
        }
        table.insert(dicePositions, position)
    end
    return dicePositions
end

return GameLoop
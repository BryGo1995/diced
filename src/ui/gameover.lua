local GameOver = {}
GameOver.__index = GameOver

local states = require("src/state").states
local Button = require("src/ui/button")
local Sprites = require("src/ui/sprites")
local fonts = require("src/ui/fonts")

local buttons = {}
local buttonWidth = 200
local buttonHeight = 60

function GameOver.new()
    local self = setmetatable({}, GameOver)
    self.title = {
        text = "GAME OVER",
        font = fonts.default,
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()/4,
        scale = 18
    }
    self.scoreDisplay = {
        score = 0,
        text = "FINAL SCORE: ",
        font = fonts.default,
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()*0.5,
        scale = 7
    }
    self.defaultFont = fonts.default
    self.nextState = nil

    return self
end

function GameOver:initializeButtons()
    buttons = {
        Button.new(
            love.graphics.getWidth()/2,
            love.graphics.getHeight()*0.75,
            {
                text = "PLAY AGAIN",
                sprite = Sprites.basicButton,
                spriteScaler = 3.6,
                font = self.defaultFont,
                textScaler = 4,
                onClick = function()
                    self.nextState = states.GAME_LOOP
                    self.scoreDisplay.score = 0
                end
            }
        ),
        Button.new(
            love.graphics.getWidth()/2,
            love.graphics.getHeight()*0.9,
            {
                text = "MENU",
                sprite = Sprites.basicButton,
                spriteScaler = 3.6,
                font = self.defaultFont,
                textScaler = 6,
                onClick = function()
                    self.nextState = states.MAIN_MENU
                    self.scoreDisplay.score = 0
                end
            }
        )
    }
end

function GameOver:init()
    self:initializeButtons()
end

function GameOver:update(dt)
    for _, b in ipairs(buttons) do
        b:update(dt)
    end
end

function GameOver:draw()
    love.graphics.setFont(self.title.font)
    local xoffset = self.title.font:getWidth(self.title.text)/2
    local yoffset = self.title.font:getHeight(self.title.text)/2
    love.graphics.print(self.title.text, self.title.x, self.title.y, 0, self.title.scale, self.title.scale, xoffset, yoffset)

    love.graphics.setFont(self.scoreDisplay.font)
    local scoreText = self.scoreDisplay.text..self.scoreDisplay.score
    xoffset = self.scoreDisplay.font:getWidth(scoreText)/2
    yoffset = self.scoreDisplay.font:getHeight(scoreText)/2
    love.graphics.print(scoreText, self.scoreDisplay.x, self.scoreDisplay.y, 0, self.scoreDisplay.scale, self.scoreDisplay.scale, xoffset, yoffset)

    for _, b in ipairs(buttons) do
        b:draw()
    end
end

function GameOver:onClick(x, y)
    for _, b in ipairs(buttons) do
        if b:isPointInside(x, y) then
            b:onClick()
        end
    end
end

function GameOver:getNextState()
    return self.nextState
end

function GameOver:resetNextState()
    self.nextState = nil
end

function GameOver:writeScoreToFile()
    local SaveManager = require("src/save_manager")
    local saveManager = SaveManager.new()
    
    -- Load existing save data
    local saveData, error = saveManager:loadData()
    if not saveData then
        -- No existing save, create new one
        saveData = { lowScore = self.scoreDisplay.score }
    else
        -- Check if this is a new low score
        if self.scoreDisplay.score <= (saveData.lowScore or math.huge) then
            saveData.lowScore = self.scoreDisplay.score
        end
    end
    
    -- Save the data securely
    local success, message = saveManager:saveData(saveData)
    if not success then
        print("Failed to save score: " .. (message or "Unknown error"))
    end
end

return GameOver
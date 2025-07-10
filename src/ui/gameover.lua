local GameOver = {}
GameOver.__index = GameOver

local states = require("src/state").states
local Button = require("src/ui/button")
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
    local scaler = 5
    local padding = 10
    local playButtonWidth = self.defaultFont:getWidth("PLAY AGAIN")*scaler+padding
    local playButtonHeight = self.defaultFont:getHeight("PLAY AGAIN")*scaler+padding
    local menuButtonWidth = self.defaultFont:getWidth("MENU")*scaler+padding
    local menuButtonHeight = self.defaultFont:getHeight("MENU")*scaler+padding
    -- Play again button
    buttons = {
        Button.new(
            "PLAY AGAIN",
            love.graphics.getWidth()/2 - playButtonWidth/2,
            love.graphics.getHeight()*0.6,
            playButtonWidth,
            playButtonHeight,
            {
                font = self.defaultFont,
                textScaler = scaler,
                onClick = function()
                    self.nextState = states.GAME_LOOP
                    self.scoreDisplay.score = 0
                end
            }
        ),
        Button.new(
            "MENU",
            love.graphics.getWidth()/2 - buttonWidth/2,
            love.graphics.getHeight()*0.7,
            menuButtonWidth,
            menuButtonHeight,
            {
                font = self.defaultFont,
                textScaler = scaler,
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

return GameOver
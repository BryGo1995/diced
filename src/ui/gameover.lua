local GameOver = {}
GameOver.__index = GameOver

local states = require("state").states
local Button = require("ui/button")

local buttons = {}
local buttonWidth = 200
local buttonHeight = 60

function GameOver.new()
    local self = setmetatable({}, GameOver)
    self.title = {
        text = "GAME OVER",
        font = love.graphics.newFont(144),
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()/3
    }
    self.nextState = nil

    return self
end

function GameOver:initializeButtons()
    -- Play again button
    buttons = {
        Button.new(
            "Play Again",
            love.graphics.getWidth()/2 - buttonWidth/2,
            love.graphics.getHeight()*0.6,
            buttonWidth,
            buttonHeight,
            {
                font = love.graphics.setNewFont(30),
                onClick = function()
                    self.nextState = states.GAME_LOOP
                end
            }
        ),
        Button.new(
            "Main Menu",
            love.graphics.getWidth()/2 - buttonWidth/2,
            love.graphics.getHeight()*0.7,
            buttonWidth,
            buttonHeight,
            {
                font = love.graphics.setNewFont(30),
                onClick = function()
                    self.nextState = states.MAIN_MENU
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
    love.graphics.print(self.title.text, self.title.x - xoffset, self.title.y - yoffset)

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

return GameOver
require("conf")

local stateMachine = require("state").stateMachine
local states = require("state").states
local Menu = require("ui/menu")
local Button = require("ui/button")

function love.load()
    -- Initialize the game state machine
    gameState = stateMachine.new() 

    -- Initialize the main menu module
    menu = Menu.new()
    menu:init()

end

function love.update(dt)
    menu:update(dt)
end

function love.draw()
    local currentState = gameState:getState()
    if currentState == states.MAIN_MENU then
        menu:draw()
    end
end

function love.mousepressed(x, y, button)
    local currentState = gameState:getState()
    if currentState == states.MAIN_MENU then
        print("Main Menu")
        menu:onClick(x, y)
        if menu:exitStatus() then
            gameState:changeState(states.GAME_LOOP)
        end
    elseif currentState == states.GAME_LOOP then
        print("Game")
        gameState:changeState(states.GAME_OVER)
    elseif currentState == states.GAME_OVER then
        print("Game Over")
        gameState:changeState(states.MAIN_MENU)
    else
        print("Invalid state")
    end
end
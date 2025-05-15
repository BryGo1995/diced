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

    -- Initialize a button
    startButton = Button.new("Start Game", 100, 100, 200, 50, {})
end

function love.update(dt)
    startButton:update()
end

function love.draw()
    local currentState = gameState:getState()
    if currentState == states.MAIN_MENU then
        menu:draw()
        startButton:draw()
    end
end

function love.mousepressed(x, y, button)
    local currentState = gameState:getState()
    if currentState == states.MAIN_MENU then
        print("Main Menu")
        if startButton:isPointInside(x, y) then
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
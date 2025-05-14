require("conf")

local stateMachine = require("state").stateMachine
local states = require("state").states

function love.load()
    -- Initialize the game state machine
    gameState = stateMachine.new() 
end

function love.update(dt)

end

function love.draw()

end

function love.mousepressed(x, y, button)
    if gameState:getState() == states.MAIN_MENU then
        print("Main Menu")
        gameState:changeState(states.GAME_LOOP)
    elseif gameState:getState() == states.GAME_LOOP then
        print("Game")
        gameState:changeState(states.GAME_OVER)
    elseif gameState:getState() == states.GAME_OVER then
        print("Game Over")
        gameState:changeState(states.MAIN_MENU)
    else
        print("Invalid state")
    end
end
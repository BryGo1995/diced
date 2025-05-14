require("conf")

local stateMachine = require("state").stateMachine
local states = require("state").states

function love.load()
    -- Initialize the game state machine
    print("hello")
    gameState = stateMachine.new() 
end

function love.update(dt)

    if gameState:getState() == states.MAIN_MENU then
        print("Main Menu")
        if love.keyboard.isDown("space") then
            gameState:changeState(states.GAME_LOOP)
        end
    elseif gameState:getState() == states.GAME_LOOP then
        print("Game")
        if love.keyboard.isDown("space") then
            gameState:changeState(states.GAME_OVER)
        end
    else
        print("Game Over")
        if love.keyboard.isDown("space") then
            gameState:changeState(states.MAIN_MENU)
        end
    end
end

function love.draw()

end

function love.mousepressed(x, y, button)

end
require("conf")

local stateMachine = require("src/state").stateMachine
local states = require("src/state").states
local Menu = require("src/ui/menu")
local Button = require("src/ui/button")
local GameLoop = require("src/ui/gameloop")
local GameOver = require("src/ui/gameover")

function love.load()
    -- Initialize the game state machine
    gameState = stateMachine.new() 

    -- Initialize the main menu module
    menu = Menu.new()
    menu:init()

    -- Initialize the game loop module
    gameLoop = GameLoop.new(20)
    gameLoop:init()

    -- Initialize the game over screen module
    gameOver = GameOver.new()
    gameOver:init()
end

function love.update(dt)
    menu:update(dt)
    gameLoop:update(dt)
    gameOver:update(dt)
end

function love.draw()
    local currentState = gameState:getState()
    if currentState == states.MAIN_MENU then
        menu:draw()
    elseif currentState == states.GAME_LOOP then
        gameLoop:draw()
    elseif currentState == states.GAME_OVER then
        gameOver:draw()
    end
end

function love.mousepressed(x, y, button)
    local currentState = gameState:getState()
    if currentState == states.MAIN_MENU then
        print("Main Menu")
        menu:onClick(x, y)
        if menu:getExitStatus() then
            gameState:changeState(states.GAME_LOOP)
            menu:resetExitStatus()
        end
    elseif currentState == states.GAME_LOOP then
        print("Game")
        gameState:changeState(states.GAME_OVER)
    elseif currentState == states.GAME_OVER then
        print("Game Over")
        gameOver:onClick(x, y)
        if gameOver:getNextState() ~= nil then
            gameState:changeState(gameOver:getNextState())
            gameOver:resetNextState()
        end
    else
        print("Invalid state")
    end
end
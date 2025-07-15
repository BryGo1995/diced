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
    gameLoop = GameLoop.new(7, 6, 5, 2)
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
        menu:onClick(x, y)
        if menu:getExitStatus() then
            gameState:changeState(states.GAME_LOOP)
            gameLoop:init()
            menu:resetExitStatus()
        end
    elseif currentState == states.GAME_LOOP then
        gameLoop:onClick(x, y)
        if gameLoop:isGameOver() then
            gameState:changeState(states.GAME_OVER)
            gameOver.scoreDisplay.score = gameLoop.score
        end
    elseif currentState == states.GAME_OVER then
        gameOver:writeScoreToFile()
        gameOver:onClick(x, y)
        if gameOver:getNextState() ~= nil then
            gameState:changeState(gameOver:getNextState())
            gameOver:resetNextState()
            gameLoop:init()
            menu:init()
        end
    else
        print("Invalid state")
    end
end
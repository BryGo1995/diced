local STATES = {
    MAIN_MENU = "main_menu",
    GAME_LOOP = "game_loop",
    GAME_OVER = "game_over",
}

local stateMachine = {}
stateMachine.__index = stateMachine

function stateMachine.new()
    local self = setmetatable({}, stateMachine)
    self.currentState = MAIN_MENU -- Initialize game at the main menu
    self.score = 0
    return self
end

function stateMachine:changeState(newState)
    self.currentState = newState
end

function stateMachine:getState()
    return self.currentState
end

function stateMachine:setScore(newScore)
    self.score = newScore
end

function stateMachine:getScore()
    return self.score
end

return {
    states = STATES,
    stateMachine = stateMachine
}
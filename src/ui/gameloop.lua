local GameLoop = {}
GameLoop.__index = GameLoop

function GameLoop.new()
    local self = setmetatable({}, GameLoop)
    self.sprites = {}
    self.score = 0

    return self
end

function GameLoop:init()
    -- Load the sprites here
    self.sprites.d6_1 = love.graphics.newImage("assets/sprites/d6-w/D6-1.png")
    self.sprites.d6_2 = love.graphics.newImage("assets/sprites/d6-w/D6-2.png")
    self.sprites.d6_3 = love.graphics.newImage("assets/sprites/d6-w/D6-3.png")
    self.sprites.d6_4 = love.graphics.newImage("assets/sprites/d6-w/D6-4.png")
    self.sprites.d6_5 = love.graphics.newImage("assets/sprites/d6-w/D6-5.png")
    self.sprites.d6_6 = love.graphics.newImage("assets/sprites/d6-w/D6-6.png")
    self.sprites.d6_blank = love.graphics.newImage("assets/sprites/d6-w/D6-0.png")
end

function GameLoop:update(dt)

end

function GameLoop:draw()
    love.graphics.draw(self.sprites.d6_1, 100, 100)
end

return GameLoop
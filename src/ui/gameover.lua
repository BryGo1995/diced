local GameOver = {}
GameOver.__index = GameOver

function GameOver.new()
    local self = setmetatable({}, GameOver)
    self.title = {
        text = "GAME OVER",
        font = love.graphics.newFont(144),
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()/2
    }

    return self
end

function GameOver:draw()
    love.graphics.setFont(self.title.font)
    local xoffset = self.title.font:getWidth(self.title.text)/2
    local yoffset = self.title.font:getHeight(self.title.text)/2
    love.graphics.print(self.title.text, self.title.x - xoffset, self.title.y - yoffset)
end

return GameOver
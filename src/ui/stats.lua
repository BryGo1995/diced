local Stats = {}
Stats.__index = Stats

function Stats.new()
    local self = setmetatable({}, Stats)

    -- Initialize with default values, will be updated later
    self.width = 400
    self.height = 300
    self.x = 100
    self.y = 100
    self.color = {0.5, 0.5, 0.5}

    return self
end

function Stats:init()
    -- Update dimensions based on current screen size
    self.width = love.graphics.getWidth()*0.5
    self.height = love.graphics.getHeight()*0.5
    self.x = love.graphics.getWidth()/2 - self.width/2
    self.y = love.graphics.getHeight()/2 - self.height/2 
    self.text = {
        x = self.x + 30,
        y = self.y + 30,
        scale = 2
    }
end

function Stats:displayStats()
    love.graphics.setColor(self.color)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    love.graphics.setColor(1, 1, 1)
end

return Stats
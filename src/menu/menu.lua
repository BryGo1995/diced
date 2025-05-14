local Menu = {}
Menu.__index = Menu

function Menu.new()
    local self = setmetatable({}, Menu)
    self.title = {
        text = "Diced",
        font = love.graphics.newFont(48),
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()/2
    }

    return self
end

function Menu:update()

end

function Menu:draw()
    love.graphics.setFont(self.title.font)
    love.graphics.print(self.title.text, self.title.x, self.title.y)
end

return Menu
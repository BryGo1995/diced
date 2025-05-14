local Menu = {}
Menu.__index = Menu

function Menu.new()
    local self = setmetatable({}, Menu)
    self.title = {
        text = "Diced",
        font = love.graphics.newFont(144),
        x = love.graphics.getWidth()/2,
        y = love.graphics.getHeight()/3,
    }

    return self
end

function Menu:update()

end

function Menu:draw()
    -- Draw the title text TODO: put in its own function
    love.graphics.setFont(self.title.font)
    local xoffset = self.title.font:getWidth(self.title.text)/2
    local yoffset = self.title.font:getHeight(self.title.text)/2
    love.graphics.print(self.title.text, self.title.x - xoffset, self.title.y - yoffset)
end

return Menu
local Button = {}
Button.__index = Button

function Button.new(text, x, y, width, height, options)
    local self = setmetatable({}, Button)

    -- Required properties
    self.text = text
    self.x = x
    self.y = y
    self.width = width
    self.height = height

    -- Optional properties
    self.options = options or {}
    self.backgroundColor = options.backgroundColor or {0.7, 0.7, 0.7}
    self.borderColor = options.borderColor or {0.3, 0.3, 0.3}
    self.textColor = options.textColor or {0, 0, 0}
    self.font = options.font or love.graphics.getFont()
    self.onClick = options.onClick or function() end
    self.hovered = false
    
    return self
end

function Button:isPointInside(x, y)
    return x >= self.x and x <= self.x + self.width and
           y >= self.y and y <= self.y + self.height
end

function Button:isHovered(x, y)
    self.hovered = self:isPointInside(x, y)
end

function Button:update(dt)
    -- Check if button is being hovered
    self:isHovered(love.mouse.getPosition())
    if self.hovered then
        self.backgroundColor = {0.8, 0.8, 0.8}
    else
        self.backgroundColor = {0.7, 0.7, 0.7}
    end
end

function Button:draw()
    -- Draw button background
    love.graphics.setColor(self.backgroundColor)
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw button border
    love.graphics.setColor(self.borderColor)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)

    -- Draw button text
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.font)
    local textX = self.x + self.width/2 - self.font:getWidth(self.text)/2
    local textY = self.y + self.height/2 - self.font:getHeight(self.text)/2
    love.graphics.print(self.text, textX, textY)

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return Button
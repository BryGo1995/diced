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
    self.backgroundColor = self.options.backgroundColor or {0.7, 0.7, 0.7}
    self.borderColor = self.options.borderColor or {0.3, 0.3, 0.3}
    self.borderWidth = self.options.borderWidth or 1
    self.textColor = self.options.textColor or {1, 1, 1}
    self.textScaler = self.options.textScaler or 1
    self.font = self.options.font or love.graphics.getFont()
    self.onClick = self.options.onClick or function() end
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

end

function Button:draw()
    -- Draw button background
    self:isHovered(love.mouse.getPosition())
    if self.hovered then 
        love.graphics.setColor({0.7, 0.7, 0.7})
    else
        love.graphics.setColor(self.backgroundColor)
    end
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

    -- Draw button border
    love.graphics.setColor(self.borderColor)
    love.graphics.setLineWidth(self.borderWidth)
    love.graphics.rectangle("line", self.x, self.y, self.width, self.height)
    love.graphics.setLineWidth(1)

    -- Draw button text
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.font)
    local textX = self.x + self.width/2 - self.font:getWidth(self.text)*self.textScaler/2
    local textY = self.y + self.height/2 - self.font:getHeight(self.text)*self.textScaler/2
    love.graphics.print(self.text, textX, textY, 0, self.textScaler, self.textScaler)

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return Button
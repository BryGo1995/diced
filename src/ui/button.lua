local Button = {}
Button.__index = Button

function Button.new(x, y, options)
    local self = setmetatable({}, Button)

    -- Required properties
    self.x = x
    self.y = y

    -- Optional properties
    self.options = options or {}
    self.text = self.options.text or "BUTTON"
    self.sprite = self.options.sprite or nil
    self.spriteScaler = self.options.spriteScaler or 1
    self.width = self.options.width or self.sprite:getWidth()*self.spriteScaler or nil
    self.height = self.options.height or self.sprite:getHeight()*self.spriteScaler or nil
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
    local hitboxX = self.x - self.width/2
    local hitboxY = self.y - self.height/2
    return x >= hitboxX and x <= hitboxX + self.width and
           y >= hitboxY and y <= hitboxY + self.height
end

function Button:isHovered(x, y)
    self.hovered = self:isPointInside(x, y)
end

function Button:update(dt)
    self:isHovered(love.mouse.getPosition())
end

function Button:draw()
    if self.sprite == nil then
        -- Draw button background
        if self.hovered then 
            love.graphics.setColor({0.7, 0.7, 0.7})
        else
            love.graphics.setColor(self.backgroundColor)
        end

        -- Draw filled rectangle
        local rectangleX = self.x - self.width/2
        local rectangleY = self.y - self.height/2
        love.graphics.rectangle("fill", rectangleX, rectangleY, self.width, self.height)

        -- Draw button border
        love.graphics.setColor(self.borderColor)
        love.graphics.setLineWidth(self.borderWidth)
        love.graphics.rectangle("line", rectangleX, rectangleY, self.width, self.height)
        love.graphics.setLineWidth(1)
        love.graphics.setColor(1, 1, 1)
    end

    -- Draw button sprite if available
    if(self.sprite ~= nil) then
        local spriteX = self.x - self.width/2
        local spriteY = self.y - self.height/2
        love.graphics.draw(self.sprite, spriteX, spriteY, 0, self.spriteScaler, self.spriteScaler)
    end

    -- Draw button text
    love.graphics.setColor(self.textColor)
    love.graphics.setFont(self.font)
    local textX = self.x - self.font:getWidth(self.text)*self.textScaler/2
    local textY = self.y - self.font:getHeight(self.text)*self.textScaler/2
    love.graphics.print(self.text, textX, textY, 0, self.textScaler, self.textScaler)

    -- Reset color
    love.graphics.setColor(1, 1, 1)
end

return Button
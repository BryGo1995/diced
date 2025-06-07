fonts = {}

love.graphics.setDefaultFilter("nearest", "nearest")

fonts.default = love.graphics.newImageFont("assets/fonts/Mario-Font.png",
                        " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!:-?", 1)

return fonts
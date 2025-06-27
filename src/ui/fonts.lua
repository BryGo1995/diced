fonts = {}

love.graphics.setDefaultFilter("nearest", "nearest")

fonts.default = love.graphics.newImageFont("assets/fonts/Mario-Font.png",
                        " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!:-?")

fonts.diceDefault = love.graphics.newImageFont("assets/fonts/Default-Dice-Numbers.png",
                        " 0123456789-", 1)

return fonts
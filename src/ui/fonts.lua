fonts = {}

love.graphics.setDefaultFilter("nearest", "nearest")

fonts.default = love.graphics.newImageFont("assets/fonts/Mario-Font-BW.png",
                        " ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.,!:-?", 1)

fonts.diceDefault = love.graphics.newImageFont("assets/fonts/Default-Dice-Numbers.png",
                        " 0123456789-", 1)
                        
fonts.diceDots = love.graphics.newImageFont("assets/fonts/Dice-Dots.png",
                        "123456")

return fonts
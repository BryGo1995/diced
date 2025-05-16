local Logger = {}
Logger.__index = Logger

-- Log levels
Logger.LEVELS = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4
}

-- ANSI color codes for console output
local COLORS = {
    DEBUG = "\27[36m", -- Cyan
    INFO = "\27[32m",  -- Green
    WARN = "\27[33m",  -- Yellow
    ERROR = "\27[31m", -- Red
    RESET = "\27[0m"   -- Reset
}

function Logger.new(options)
    options = options or {}
    local self = setmetatable({}, Logger)
    
    self.minLevel = options.minLevel or Logger.LEVELS.DEBUG
    self.logToFile = options.logToFile or false
    self.logToConsole = options.logToConsole or true
    self.logFile = nil
    
    if self.logToFile then
        self.logFile = io.open("game.log", "a")
        if not self.logFile then
            print("Warning: Could not open log file")
            self.logToFile = false
        end
    end
    
    return self
end

function Logger:log(level, message, ...)
    if level < self.minLevel then return end
    
    local timestamp = os.date("%Y-%m-%d %H:%M:%S")
    local formattedMessage = string.format(message, ...)
    local levelName = "UNKNOWN"
    
    -- Get level name
    for name, value in pairs(Logger.LEVELS) do
        if value == level then
            levelName = name
            break
        end
    end
    
    -- Format the log entry
    local logEntry = string.format("[%s] [%s] %s\n", 
        timestamp, levelName, formattedMessage)
    
    -- Console output with colors
    if self.logToConsole then
        local color = COLORS[levelName] or COLORS.RESET
        print(color .. logEntry .. COLORS.RESET)
    end
    
    -- File output
    if self.logToFile and self.logFile then
        self.logFile:write(logEntry)
        self.logFile:flush()
    end
end

-- Convenience methods for different log levels
function Logger:debug(message, ...)
    self:log(Logger.LEVELS.DEBUG, message, ...)
end

function Logger:info(message, ...)
    self:log(Logger.LEVELS.INFO, message, ...)
end

function Logger:warn(message, ...)
    self:log(Logger.LEVELS.WARN, message, ...)
end

function Logger:error(message, ...)
    self:log(Logger.LEVELS.ERROR, message, ...)
end

function Logger:close()
    if self.logFile then
        self.logFile:close()
        self.logFile = nil
    end
end

return Logger 
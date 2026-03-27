-- Simple JSON library for Lua
local json = {}

-- Escape special characters in strings
local function escapeString(str)
    local escapes = {
        ['\\'] = '\\\\',
        ['"'] = '\\"',
        ['\n'] = '\\n',
        ['\r'] = '\\r',
        ['\t'] = '\\t'
    }
    
    return str:gsub('[\\"\n\r\t]', escapes)
end

-- Serialize a value to JSON
function json.encode(value)
    local valueType = type(value)
    
    if valueType == "nil" then
        return "null"
    elseif valueType == "boolean" then
        return tostring(value)
    elseif valueType == "number" then
        if value ~= value then -- NaN
            return "null"
        elseif value == math.huge then
            return "null"
        elseif value == -math.huge then
            return "null"
        else
            return tostring(value)
        end
    elseif valueType == "string" then
        return '"' .. escapeString(value) .. '"'
    elseif valueType == "table" then
        local result = "{"
        local first = true
        
        for k, v in pairs(value) do
            if not first then
                result = result .. ","
            end
            first = false
            
            if type(k) == "string" then
                result = result .. '"' .. escapeString(k) .. '":'
            else
                result = result .. '[' .. json.encode(k) .. ']:'
            end
            
            result = result .. json.encode(v)
        end
        
        return result .. "}"
    else
        error("Cannot encode value of type " .. valueType)
    end
end

-- Parse JSON string (simplified version)
function json.decode(str)
    -- This is a simplified JSON parser
    -- For production use, consider using a more robust library
    
    local pos = 1
    
    local function skipWhitespace()
        while pos <= #str and str:sub(pos, pos):match("%s") do
            pos = pos + 1
        end
    end
    
    local function parseValue()
        skipWhitespace()
        local char = str:sub(pos, pos)
        
        if char == '"' then
            -- Parse string
            pos = pos + 1
            local result = ""
            while pos <= #str and str:sub(pos, pos) ~= '"' do
                if str:sub(pos, pos) == "\\" then
                    pos = pos + 1
                    local nextChar = str:sub(pos, pos)
                    if nextChar == "n" then
                        result = result .. "\n"
                    elseif nextChar == "r" then
                        result = result .. "\r"
                    elseif nextChar == "t" then
                        result = result .. "\t"
                    elseif nextChar == "\\" then
                        result = result .. "\\"
                    elseif nextChar == '"' then
                        result = result .. '"'
                    else
                        result = result .. nextChar
                    end
                else
                    result = result .. str:sub(pos, pos)
                end
                pos = pos + 1
            end
            pos = pos + 1
            return result
        elseif char == "{" then
            -- Parse object
            pos = pos + 1
            local result = {}
            skipWhitespace()
            
            if str:sub(pos, pos) == "}" then
                pos = pos + 1
                return result
            end
            
            while true do
                skipWhitespace()
                local key = parseValue()
                skipWhitespace()
                
                if str:sub(pos, pos) ~= ":" then
                    error("Expected ':' at position " .. pos)
                end
                pos = pos + 1
                
                local value = parseValue()
                result[key] = value
                
                skipWhitespace()
                if str:sub(pos, pos) == "}" then
                    pos = pos + 1
                    break
                elseif str:sub(pos, pos) == "," then
                    pos = pos + 1
                else
                    error("Expected ',' or '}' at position " .. pos)
                end
            end
            
            return result
        elseif char == "[" then
            -- Parse array
            pos = pos + 1
            local result = {}
            skipWhitespace()
            
            if str:sub(pos, pos) == "]" then
                pos = pos + 1
                return result
            end
            
            local index = 1
            while true do
                local value = parseValue()
                result[index] = value
                index = index + 1
                
                skipWhitespace()
                if str:sub(pos, pos) == "]" then
                    pos = pos + 1
                    break
                elseif str:sub(pos, pos) == "," then
                    pos = pos + 1
                else
                    error("Expected ',' or ']' at position " .. pos)
                end
            end
            
            return result
        elseif char == "t" and str:sub(pos, pos + 3) == "true" then
            pos = pos + 4
            return true
        elseif char == "f" and str:sub(pos, pos + 4) == "false" then
            pos = pos + 5
            return false
        elseif char == "n" and str:sub(pos, pos + 3) == "null" then
            pos = pos + 4
            return nil
        elseif char:match("%d") or char == "-" then
            -- Parse number
            local numStr = ""
            while pos <= #str and str:sub(pos, pos):match("[%d%.%-%+eE]") do
                numStr = numStr .. str:sub(pos, pos)
                pos = pos + 1
            end
            return tonumber(numStr)
        else
            error("Unexpected character '" .. char .. "' at position " .. pos)
        end
    end
    
    local result = parseValue()
    skipWhitespace()
    if pos <= #str then
        error("Unexpected data after JSON at position " .. pos)
    end
    
    return result
end

return json

local SaveManager = {}
SaveManager.__index = SaveManager

-- Simple XOR encryption key (you can change this to any string)
local ENCRYPTION_KEY = "DicedGame2024!@#"
local SAVE_FILE = "game_save.dat"
local HASH_FILE = "game_save.hash"

-- Simple hash function for integrity checking
local function simpleHash(data)
    local hash = 0
    for i = 1, #data do
        local byte = string.byte(data, i)
        hash = ((hash * 31) + byte) % 0x100000000
    end
    return string.format("%08x", hash)
end

-- XOR encryption/decryption
local function xorEncrypt(data, key)
    local result = ""
    local keyLen = #key
    for i = 1, #data do
        local dataByte = string.byte(data, i)
        local keyByte = string.byte(key, (i - 1) % keyLen + 1)
        local encryptedByte = bit.bxor(dataByte, keyByte)
        result = result .. string.char(encryptedByte)
    end
    return result
end

-- Encode data to base64-like format (simple implementation)
local function encode(data)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = ""
    local i = 1
    
    while i <= #data do
        local b1 = string.byte(data, i) or 0
        local b2 = string.byte(data, i + 1) or 0
        local b3 = string.byte(data, i + 2) or 0
        
        local c1 = bit.rshift(b1, 2)
        local c2 = bit.lshift(bit.band(b1, 3), 4) + bit.rshift(b2, 4)
        local c3 = bit.lshift(bit.band(b2, 15), 2) + bit.rshift(b3, 6)
        local c4 = bit.band(b3, 63)
        
        result = result .. string.sub(chars, c1 + 1, c1 + 1)
        result = result .. string.sub(chars, c2 + 1, c2 + 1)
        result = result .. string.sub(chars, c3 + 1, c3 + 1)
        result = result .. string.sub(chars, c4 + 1, c4 + 1)
        
        i = i + 3
    end
    
    return result
end

-- Decode from base64-like format
local function decode(data)
    local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
    local result = ""
    
    for i = 1, #data, 4 do
        local c1 = string.find(chars, string.sub(data, i, i), 1, true) - 1
        local c2 = string.find(chars, string.sub(data, i + 1, i + 1), 1, true) - 1
        local c3 = string.find(chars, string.sub(data, i + 2, i + 2), 1, true) - 1
        local c4 = string.find(chars, string.sub(data, i + 3, i + 3), 1, true) - 1
        
        local b1 = bit.lshift(c1, 2) + bit.rshift(c2, 4)
        local b2 = bit.lshift(bit.band(c2, 15), 4) + bit.rshift(c3, 2)
        local b3 = bit.lshift(bit.band(c3, 3), 6) + c4
        
        result = result .. string.char(b1)
        if c3 ~= 64 then
            result = result .. string.char(b2)
        end
        if c4 ~= 64 then
            result = result .. string.char(b3)
        end
    end
    
    return result
end

function SaveManager.new()
    local self = setmetatable({}, SaveManager)
    return self
end

-- Save data with encryption and integrity checking
function SaveManager:saveData(data)
    -- Convert data to JSON-like string
    local dataString = self:serializeData(data)
    
    -- Encrypt the data
    local encryptedData = xorEncrypt(dataString, ENCRYPTION_KEY)
    
    -- Encode for safe storage
    local encodedData = encode(encryptedData)
    
    -- Create integrity hash
    local hash = simpleHash(dataString)
    
    -- Save encrypted data
    local success = love.filesystem.write(SAVE_FILE, encodedData)
    if not success then
        return false, "Failed to write save file"
    end
    
    -- Save hash for integrity checking
    success = love.filesystem.write(HASH_FILE, hash)
    if not success then
        return false, "Failed to write hash file"
    end
    
    return true, "Save successful"
end

-- Load and decrypt data with integrity checking
function SaveManager:loadData()
    -- Check if save file exists
    if not love.filesystem.getInfo(SAVE_FILE) then
        return nil, "No save file found"
    end
    
    -- Check if hash file exists
    if not love.filesystem.getInfo(HASH_FILE) then
        return nil, "Hash file missing - save may be corrupted"
    end
    
    -- Read encrypted data
    local encodedData = love.filesystem.read(SAVE_FILE)
    if not encodedData then
        return nil, "Failed to read save file"
    end
    
    -- Read hash
    local storedHash = love.filesystem.read(HASH_FILE)
    if not storedHash then
        return nil, "Failed to read hash file"
    end
    
    -- Decode data
    local encryptedData = decode(encodedData)
    if not encryptedData then
        return nil, "Failed to decode save data"
    end
    
    -- Decrypt data
    local decryptedData = xorEncrypt(encryptedData, ENCRYPTION_KEY)
    if not decryptedData then
        return nil, "Failed to decrypt save data"
    end
    
    -- Verify integrity
    local calculatedHash = simpleHash(decryptedData)
    if calculatedHash ~= storedHash then
        return nil, "Save file integrity check failed - file may have been tampered with"
    end
    
    -- Deserialize data
    local data = self:deserializeData(decryptedData)
    if not data then
        return nil, "Failed to deserialize save data"
    end
    
    return data, "Load successful"
end

-- Simple data serialization using JSON
function SaveManager:serializeData(data)
    local json = require("docs/tools/json")
    return json.encode(data)
end

-- Simple data deserialization using JSON
function SaveManager:deserializeData(dataString)
    local json = require("docs/tools/json")
    return json.decode(dataString)
end

-- Check if save file exists and is valid
function SaveManager:hasValidSave()
    if not love.filesystem.getInfo(SAVE_FILE) then
        return false
    end
    
    local data, error = self:loadData()
    return data ~= nil
end

-- Delete save file
function SaveManager:deleteSave()
    love.filesystem.remove(SAVE_FILE)
    love.filesystem.remove(HASH_FILE)
end

-- Get save file info
function SaveManager:getSaveInfo()
    local info = love.filesystem.getInfo(SAVE_FILE)
    if not info then
        return nil
    end
    
    return {
        size = info.size,
        modified = info.modtime,
        exists = true
    }
end

return SaveManager

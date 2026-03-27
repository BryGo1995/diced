-- Save system utilities for debugging and management
local SaveUtils = {}

local SaveManager = require("src/core/save_manager")

-- Print save file information
function SaveUtils.printSaveInfo()
    local saveManager = SaveManager.new()
    local info = saveManager:getSaveInfo()
    
    if info then
        print("=== Save File Information ===")
        print("File exists: " .. tostring(info.exists))
        print("File size: " .. tostring(info.size) .. " bytes")
        print("Last modified: " .. os.date("%Y-%m-%d %H:%M:%S", info.modified))
        
        -- Try to load and display save data
        local data, error = saveManager:loadData()
        if data then
            print("Save data loaded successfully:")
            SaveUtils.printTable(data, "  ")
        else
            print("Failed to load save data: " .. (error or "Unknown error"))
        end
    else
        print("No save file found")
    end
    print("==============================")
end

-- Print a table in a readable format
function SaveUtils.printTable(tbl, indent)
    indent = indent or ""
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            print(indent .. tostring(key) .. " = {")
            SaveUtils.printTable(value, indent .. "  ")
            print(indent .. "}")
        else
            print(indent .. tostring(key) .. " = " .. tostring(value))
        end
    end
end

-- Test the save system
function SaveUtils.testSaveSystem()
    print("=== Testing Save System ===")
    
    local saveManager = SaveManager.new()
    
    -- Test 1: Save some data
    print("Test 1: Saving test data...")
    local testData = {
        lowScore = 150,
        playerName = "TestPlayer",
        achievements = {"First Game", "Low Score"},
        settings = {
            soundEnabled = true,
            musicVolume = 0.8
        }
    }
    
    local success, message = saveManager:saveData(testData)
    if success then
        print("✓ Save successful: " .. message)
    else
        print("✗ Save failed: " .. message)
        return
    end
    
    -- Test 2: Load the data back
    print("Test 2: Loading saved data...")
    local loadedData, error = saveManager:loadData()
    if loadedData then
        print("✓ Load successful: " .. error)
        print("Loaded data:")
        SaveUtils.printTable(loadedData, "  ")
    else
        print("✗ Load failed: " .. error)
        return
    end
    
    -- Test 3: Verify data integrity
    print("Test 3: Verifying data integrity...")
    local isEqual = true
    for key, value in pairs(testData) do
        if type(value) == "table" then
            for subKey, subValue in pairs(value) do
                if loadedData[key] and loadedData[key][subKey] ~= subValue then
                    isEqual = false
                    print("✗ Data mismatch at " .. key .. "." .. subKey)
                end
            end
        elseif loadedData[key] ~= value then
            isEqual = false
            print("✗ Data mismatch at " .. key)
        end
    end
    
    if isEqual then
        print("✓ Data integrity verified - all data matches")
    else
        print("✗ Data integrity check failed")
    end
    
    -- Test 4: Test tampering detection
    print("Test 4: Testing tampering detection...")
    local saveInfo = love.filesystem.getInfo("game_save.dat")
    if saveInfo then
        -- Try to modify the save file directly
        local currentData = love.filesystem.read("game_save.dat")
        local modifiedData = currentData .. "TAMPERED"
        love.filesystem.write("game_save.dat", modifiedData)
        
        -- Try to load the tampered file
        local tamperedData, tamperError = saveManager:loadData()
        if not tamperedData then
            print("✓ Tampering detection working: " .. tamperError)
        else
            print("✗ Tampering detection failed - loaded tampered data")
        end
        
        -- Restore the original data
        love.filesystem.write("game_save.dat", currentData)
    end
    
    print("=== Save System Test Complete ===")
end

-- Backup current save file
function SaveUtils.backupSave()
    local saveManager = SaveManager.new()
    local info = saveManager:getSaveInfo()
    
    if not info then
        print("No save file to backup")
        return
    end
    
    local timestamp = os.date("%Y%m%d_%H%M%S")
    local backupName = "game_save_backup_" .. timestamp .. ".dat"
    local hashBackupName = "game_save_backup_" .. timestamp .. ".hash"
    
    -- Copy save file
    local saveData = love.filesystem.read("game_save.dat")
    local hashData = love.filesystem.read("game_save.hash")
    
    if saveData and hashData then
        love.filesystem.write(backupName, saveData)
        love.filesystem.write(hashBackupName, hashData)
        print("✓ Save file backed up as: " .. backupName)
        print("✓ Hash file backed up as: " .. hashBackupName)
    else
        print("✗ Failed to backup save files")
    end
end

-- Restore save file from backup
function SaveUtils.restoreSave(backupName)
    if not backupName then
        print("Please specify backup filename")
        return
    end
    
    local saveBackup = backupName
    local hashBackup = backupName:gsub("%.dat$", ".hash")
    
    -- Check if backup files exist
    local saveInfo = love.filesystem.getInfo(saveBackup)
    local hashInfo = love.filesystem.getInfo(hashBackup)
    
    if not saveInfo or not hashInfo then
        print("✗ Backup files not found: " .. saveBackup .. " and " .. hashBackup)
        return
    end
    
    -- Backup current save first
    SaveUtils.backupSave()
    
    -- Restore from backup
    local saveData = love.filesystem.read(saveBackup)
    local hashData = love.filesystem.read(hashBackup)
    
    if saveData and hashData then
        love.filesystem.write("game_save.dat", saveData)
        love.filesystem.write("game_save.hash", hashData)
        print("✓ Save file restored from: " .. backupName)
        
        -- Verify the restored save
        local saveManager = SaveManager.new()
        local data, error = saveManager:loadData()
        if data then
            print("✓ Restored save file is valid")
        else
            print("✗ Restored save file is corrupted: " .. error)
        end
    else
        print("✗ Failed to restore save files")
    end
end

-- List all backup files
function SaveUtils.listBackups()
    local files = love.filesystem.getDirectoryItems("")
    local backups = {}
    
    for _, file in ipairs(files) do
        if file:match("^game_save_backup_.*%.dat$") then
            local info = love.filesystem.getInfo(file)
            if info then
                table.insert(backups, {
                    name = file,
                    size = info.size,
                    modified = info.modtime
                })
            end
        end
    end
    
    if #backups == 0 then
        print("No backup files found")
        return
    end
    
    print("=== Available Backups ===")
    table.sort(backups, function(a, b) return a.modified > b.modified end)
    
    for i, backup in ipairs(backups) do
        print(string.format("%d. %s", i, backup.name))
        print("   Size: " .. backup.size .. " bytes")
        print("   Date: " .. os.date("%Y-%m-%d %H:%M:%S", backup.modified))
        print()
    end
end

-- Clear all save data
function SaveUtils.clearAllSaves()
    print("=== Clearing All Save Data ===")
    
    local saveManager = SaveManager.new()
    saveManager:deleteSave()
    
    -- Also remove any backup files
    local files = love.filesystem.getDirectoryItems("")
    local removedCount = 0
    
    for _, file in ipairs(files) do
        if file:match("^game_save") then
            love.filesystem.remove(file)
            removedCount = removedCount + 1
        end
    end
    
    print("✓ Removed " .. removedCount .. " save-related files")
    print("✓ All save data cleared")
end

return SaveUtils

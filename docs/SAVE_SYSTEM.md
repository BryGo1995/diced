# Secure Save System for Diced Game

This document explains how to use the new encrypted save system that prevents tampering with game save data.

## Overview

The secure save system provides three main security features:

1. **Encryption** - Save data is encrypted using XOR encryption with a custom key
2. **Integrity Checking** - A hash is generated and stored separately to detect tampering
3. **Data Validation** - The system validates data structure and content

## Files

- `src/save_manager.lua` - Main save manager with encryption and integrity checking
- `src/json.lua` - JSON serialization/deserialization library
- `src/save_utils.lua` - Utility functions for debugging and managing saves
- `SAVE_SYSTEM_README.md` - This documentation file

## How It Works

### Encryption Process
1. Game data is serialized to JSON format
2. JSON string is encrypted using XOR encryption with a secret key
3. Encrypted data is encoded to base64-like format for safe storage
4. A hash of the original data is generated and stored separately
5. Both files are saved to disk

### Decryption Process
1. Encrypted data is read from disk
2. Data is decoded from base64-like format
3. Data is decrypted using the same secret key
4. Hash is verified to ensure data integrity
5. Data is deserialized back to Lua tables

## Usage

### Basic Save Operations

```lua
local SaveManager = require("src/save_manager")
local saveManager = SaveManager.new()

-- Save data
local gameData = {
    lowScore = 150,
    playerName = "Player1",
    achievements = {"First Win", "Low Score"},
    settings = {
        soundEnabled = true,
        musicVolume = 0.8
    }
}

local success, message = saveManager:saveData(gameData)
if success then
    print("Save successful: " .. message)
else
    print("Save failed: " .. message)
end

-- Load data
local loadedData, error = saveManager:loadData()
if loadedData then
    print("Load successful: " .. error)
    -- Use loadedData.lowScore, loadedData.playerName, etc.
else
    print("Load failed: " .. error)
end
```

### Checking Save Status

```lua
-- Check if a valid save exists
if saveManager:hasValidSave() then
    print("Valid save file found")
else
    print("No valid save file")
end

-- Get save file information
local info = saveManager:getSaveInfo()
if info then
    print("Save file size: " .. info.size .. " bytes")
    print("Last modified: " .. os.date("%Y-%m-%d %H:%M:%S", info.modified))
end
```

### Managing Save Files

```lua
-- Delete save file
saveManager:deleteSave()

-- Backup current save
local SaveUtils = require("src/save_utils")
SaveUtils.backupSave()

-- List available backups
SaveUtils.listBackups()

-- Restore from backup
SaveUtils.restoreSave("game_save_backup_20241201_143022.dat")

-- Clear all save data
SaveUtils.clearAllSaves()
```

## Security Features

### Encryption Key
The encryption key is defined in `src/save_manager.lua`:

```lua
local ENCRYPTION_KEY = "DicedGame2024!@#"
```

**Important**: Change this key to something unique for your game. The key should be:
- At least 16 characters long
- Include a mix of letters, numbers, and special characters
- Not easily guessable

### Integrity Checking
The system uses a simple hash function to detect tampering:

- If someone modifies the encrypted save file, the hash won't match
- If someone modifies the hash file, the data won't decrypt properly
- Both files must be intact for the save to load

### File Structure
- `game_save.dat` - Encrypted and encoded save data
- `game_save.hash` - Hash for integrity checking

## Testing the System

Use the utility functions to test your save system:

```lua
local SaveUtils = require("src/save_utils")

-- Run comprehensive tests
SaveUtils.testSaveSystem()

-- View save information
SaveUtils.printSaveInfo()
```

## Migration from Old System

The old system used plain text files (`lowscore.txt`). The new system automatically handles this transition:

1. Old saves will continue to work until replaced
2. New saves will use the encrypted format
3. You can manually migrate by loading old data and saving with the new system

## Customization

### Adding New Data Types
The JSON library supports:
- Numbers, strings, booleans
- Tables (nested objects)
- Arrays
- Nil values

### Extending Save Data
```lua
local saveData = {
    lowScore = 150,
    highScore = 500,
    totalGames = 25,
    achievements = {"First Win", "Low Score"},
    playerStats = {
        averageScore = 275.5,
        bestTime = 120.3,
        favoriteDice = "d6"
    },
    settings = {
        soundEnabled = true,
        musicVolume = 0.8,
        difficulty = "normal"
    }
}
```

### Changing File Names
Modify these constants in `src/save_manager.lua`:
```lua
local SAVE_FILE = "my_custom_save.dat"
local HASH_FILE = "my_custom_save.hash"
```

## Troubleshooting

### Common Issues

1. **"Save file integrity check failed"**
   - The save file has been modified or corrupted
   - Try restoring from a backup
   - Delete the save and start fresh

2. **"Failed to decrypt save data"**
   - The encryption key may have changed
   - The save file format may be incompatible
   - Check if the save file is from a different version

3. **"Hash file missing"**
   - The hash file was deleted or corrupted
   - The save file may still work but integrity can't be verified
   - Consider deleting and starting fresh

### Debug Information
Use the utility functions to diagnose issues:
```lua
SaveUtils.printSaveInfo()  -- Shows save file details
SaveUtils.testSaveSystem() -- Runs comprehensive tests
```

## Performance Considerations

- **Encryption/Decryption**: XOR encryption is very fast
- **Hash Calculation**: Simple hash function is efficient
- **File I/O**: Minimal overhead compared to plain text saves
- **Memory Usage**: JSON serialization uses minimal temporary memory

## Security Limitations

This system provides basic protection against casual tampering but is not cryptographically secure:

- **XOR Encryption**: Can be broken with enough analysis
- **Simple Hash**: Not resistant to sophisticated attacks
- **Key Storage**: Key is stored in plain text in the source code

For commercial games requiring high security, consider:
- Using a proper encryption library (AES, etc.)
- Implementing key derivation functions
- Adding additional integrity checks
- Using platform-specific secure storage

## Support

If you encounter issues:
1. Check the console for error messages
2. Use the utility functions to diagnose problems
3. Verify file permissions and disk space
4. Test with the provided test functions

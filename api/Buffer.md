---
theme: default
---

## Buffer

An object created when calling [`BufferModule:CreateBuffer()`]() or [`BufferModule.new()`]().

```lua
local tool = script.Parent
local BufferModule = require(somewhere.BufferModule)

-- Create a buffer attached to the tool this script is in and name it 'Projectile Buffer'
local buffer = BufferModule.new(tool, "ProjectileBuffer")
```

## Properties

### INSTANCE <font color='FireBrick'>Read Only</font>
- Buffer.INSTANCE: [Instance](https://developer.roblox.com/api-reference/class/Instance)

References the Instance that the Buffer was attached to when created.

### <font color='blue'>Server:</font> <a name="itemContainer"></a> itemContainer <font color='FireBrick'>[Read Only]</font>
- Buffer.itemContainer: [Folder](https://developer.roblox.com/api-reference/class/Folder)

References the folder created by the Buffer to store items. The folder (in most cases) will be stored as a child of the instance the buffer is attached to.

## Functions

### new
- Buffer.new(attachTo: [Instance](https://developer.roblox.com/api-reference/class/Instance), name: string?): Buffer

Constructs a new Buffer object. If no name is provided, the Buffer's [Item Container](#itemContainer) will be called 'UnnamedBuffer' by default.

**Note:** If you want to have multiple Buffers underneath the same object, a name **must** be provided to avoid conflict!

### GetUnsortedItems
- Buffer:GetUnsortedItems(): [Instance](https://developer.roblox.com/api-reference/class/Instance)

Returns a table of all items that are currently in the Buffer. 

## Events

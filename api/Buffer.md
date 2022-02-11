---
theme: default
---

## Buffer 3

An object created when calling [`BufferModule:CreateBuffer()`]() or [`BufferModule.new()`]().

```lua
local tool = script.Parent
local BufferModule = require(somewhere.BufferModule)

-- Create a buffer attached to the tool this script is in and name it 'Projectile Buffer'
local buffer = BufferModule.new(tool, "ProjectileBuffer")
```

## Properties

### INSTANCE <span class="read-only-tag"/>
- Buffer.INSTANCE: [Instance](https://developer.roblox.com/api-reference/class/Instance)

References the Instance that the Buffer was attached to when created.

### itemContainer <span class="read-only-tag"/>
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

### <span class="server-prefix"/> Refill()
- Buffer:Refill()

Refills the buffer using the provided function set with `SetItemConstructer`. This will insure that the Buffer has at least the amount of items specified with `SetMinimumItems`, or one by default.

```lua
buffer:SetMinimumItems(4) -- Set the amount the buffer will refill to.
buffer:Refill() -- Refill the buffer. This will add 4 items to the buffer's ItemContainer.
Buffer:Refill() -- The buffer is already full, so this will do nothing.
```

### <span class="server-prefix"/> SetAutoRefillEnabled
- Buffer:SetAutoRefillEnabled(enabled: boolean)

If true, the Buffer will automatically refill when it goes underneath the threshold specified by minimum items threshold (one by default).

The Buffer will not refill automatically by default.

```lua
local buffer = BufferModule.new(tool, "ProjectileBuffer") -- Creates a new buffer.

buffer:SetItemConstructor(function() -- Set the function to be called when creating items for the buffer.
  return Instance.new("BasePart")
end)

buffer:SetAutoRefillEnabled(true) -- Set the buffer to auto refill.

tool.Activated:Connect(function()
  buffer:SetCurrentPlayer(Players:GetPlayerFromCharacter(tool.Parent))
  
  -- Spawn 3 parts in the Workspace
  for i = 1, 3 do
    -- Pop an item out of the buffer
    local item: BasePart = buffer:PopItem()
    -- Reparent the item to the workspace
    item.Parent = workspace
  end
end)
```

## Events

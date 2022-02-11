---
theme: default
---

## Buffer

**(actual links need to be added here)**
An object created when calling [`BufferModule:CreateBuffer()`](/BufferModule#CreateBuffer) or [`BufferModule.new()`](/BufferModule#CreateBuffer).

```lua
local tool = script.Parent
local BufferModule = require(somewhere.BufferModule)

-- Create a buffer attached to the tool this script is in and name it 'Projectile Buffer'
local buffer = BufferModule.new(tool, "ProjectileBuffer")
```

- [Properties](#properties)
  - [INSTANCE](#instance-read-only)
  - [itemContainer](#instance-read-only)
- [Functions](#functions)
  - [new()](#new)
  - [Is()](#is)
  - [Destroy()](#destroy)
  - [GetUnsortedItems()](#getunsorteditems)
  - [Refill()](#server-refill)
  - [SetAutoRefillEnabled()](#server-setautorefillenabled)
  - [GetCurrentPlayer()](#server-getcurrentplayer)
  - [SetCurrentPlayer()](#server-setcurrentplayer)
  - [SetItemConstructor()](#server-setitemconstructor)
  - [AddItem()](#server-additem)
- [Events](#events)

## Properties

### INSTANCE <span class="read-only-tag">Read Only</span>
`Buffer.INSTANCE: Instance`

References the Instance that the Buffer was attached to when created.

### itemContainer <span class="read-only-tag">Read Only</span>
`Buffer.itemContainer: Folder`

References the folder created by the Buffer to store items. The folder (in most cases) will be stored as a child of the instance the buffer is attached to.

## Functions

### new
- Buffer.new(attachTo: [Instance](https://developer.roblox.com/api-reference/class/Instance), name: string?): Buffer

Constructs a new Buffer object. If no name is provided, the Buffer's [Item Container](#itemcontainer) will be called 'UnnamedBuffer' by default.

**Note:** If you want to have multiple Buffers underneath the same object, a name **must** be provided to avoid conflict!

### Is
`Buffer.Is(object: any): boolean`

Returns true/false if the provided object is a Buffer. 

### Destroy
- Buffer:Destroy():

A destructor function that disconnects all script connections. If called on the server, then the Buffer's [Item Container](#itemcontainer) will also be destroyed.

### GetUnsortedItems

`Buffer:GetUnsortedItems(): Instance`

Returns a table of all items that are currently in the Buffer. 

### <span class="server-prefix">Server:</span> Refill
`Buffer:Refill()`

Refills the buffer using the provided function set with `SetItemConstructer`. This will insure that the Buffer has at least the amount of items specified with `SetMinimumItems`, or one by default.

```lua
buffer:SetMinimumItems(4) -- Set the amount the buffer will refill to.
buffer:Refill() -- Refill the buffer. This will add 4 items to the buffer's ItemContainer.
Buffer:Refill() -- The buffer is already full, so this will do nothing.
```

### <span class="server-prefix">Server:</span> SetAutoRefillEnabled
`Buffer:SetAutoRefillEnabled(enabled: boolean): self`

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

### <span class="server-prefix">Server:</span> GetCurrentPlayer
`Buffer:GetCurrentPlayer(): Player?`

Returns the player that currently has ownership over the Buffer.

### <span class="server-prefix">Server:</span> SetMinimumItems
`Buffer:SetMinimumItems(amount: number): self`

Returns the player that currently has ownership over the Buffer. Returns `nil` if no player owns it.

### <span class="server-prefix">Server:</span> SetCurrentPlayer
`Buffer:SetCurrentPlayer(player: Player?):`

Sets the current player that owns the Buffer. This will update the NetworkOwnership of all items currently in the Buffer automatically.

This function **must be called at least once** before [`Buffer:PopItem()`](#popitem) can be used.

### <span class="server-prefix">Server:</span> SetItemConstructor
`Buffer:SetItemConstructor(func: function):`

Sets the current item constructor function to the provided function. This will be called when refilling the Buffer.

If an item constructor has already been set, the new one will override it.

### <span class="server-prefix">Server:</span> AddItem
`Buffer:AddItem(item: Model | BasePart)`

Adds a new item to the end of the Buffer. The item parameter accepts a [`Model`](https://developer.roblox.com/api-reference/class/Model) with a [`PrimaryPart`](https://developer.roblox.com/api-reference/class/PrimaryPart), or a [`BasePart`](https://developer.roblox.com/api-reference/class/BasePart).

When an item is added to a Buffer, you should not try to reposition it, change its velocity, or add active Constraints/BodyMovers. This should be done after the item is popped from the Buffer.

## Events

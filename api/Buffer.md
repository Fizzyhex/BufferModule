---
theme: default
---

# Buffer

An object created when calling [`BufferModule:CreateBuffer()`]() or [`BufferModule.new()`]().

```lua
local tool = script.Parent
local BufferModule = require(somewhere.BufferModule)

-- Create a buffer attached to the tool this script is in and name it 'Projectile Buffer'
local buffer = BufferModule.new(tool, "ProjectileBuffer")
```

## Properties

### instance *(read only)*
Buffer.instance: [Folder](https://developer.roblox.com/api-reference/class/Folder)
<font color='red'>test blue color font</font>

## Functions
`GetUnsortedItems`

## Events

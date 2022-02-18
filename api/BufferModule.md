---
theme: default
---

[< Back to main page](../)

## BufferModule

```lua
local BufferModule = require(ReplicatedStorage.BufferModule)

-- Creates a new Buffer called "MyBuffer" under whatever this script is parented to.
local buffer = BufferModule:CreateBuffer(script.Parent, "MyBuffer")
```
## Properties

## Functions

### CreateBuffer
`BufferModule:CreateBuffer(instance: Instance, bufferName: string): Buffer`

Constructs a new [Buffer](/Buffer). Shorthand for [`BufferModule.Buffer.new()`](/Buffer#new).

### Util.RegisterTouchInterest
`BufferModule.Util.RegisterTouchInterest(part: BasePart)`

Creates a [TouchTransmitter](https://developer.roblox.com/api-reference/class/TouchTransmitter) as a child of the provided Instance. If a [TouchTransmitter](https://developer.roblox.com/api-reference/class/TouchTransmitter) already exists under the provided [Instance](https://developer.roblox.com/api-reference/class/Instance) then nothing will be created.

## Events

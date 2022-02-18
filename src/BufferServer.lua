-- metavirtual, 2021
-- Handles garbage cleaning of instances created by buffers.
-- This script will automatically reparent itself when the module is ran, but you can manually parent it to ServerScriptService.

local CollectionService = game:GetService("CollectionService")
local PhysicsService = game:GetService("PhysicsService")

local Configuration = require(script.Parent.Configuration)

local bufferItems = {}

local Export = {}

local function ItemAdded(Item)
	local BufferOwnerValue = Item:WaitForChild("BufferOwner", 8)
	if BufferOwnerValue then
		if BufferOwnerValue.Value == nil then
			local start = tick()
			local timeoutAfter = 5
			while tick() - start < timeoutAfter and BufferOwnerValue.Value == nil do
				task.wait()
			end
			if BufferOwnerValue.Value == nil then
				return
			end
		end
		if bufferItems[BufferOwnerValue.Value] == nil then
			-- Create a dictonary key for the player that owns the item
			bufferItems[BufferOwnerValue.Value] = {}
		end
		
		-- Add the item to the player's buffer
		bufferItems[BufferOwnerValue.Value][Item] = true

		CollectionService:AddTag(BufferOwnerValue.Value, "BufferTool")
	end
end

local function ItemRemoving(Item)
	local BufferOwnerValue = Item:FindFirstChild("BufferOwner")
	-- Check if we have any references to this item so we can remove it from memory
	if BufferOwnerValue and BufferOwnerValue.Value and bufferItems[BufferOwnerValue.Value] then
		-- Garbage clean
		bufferItems[BufferOwnerValue.Value][Item] = nil
	end
end

local function ToolRemoving(Tool)
	if bufferItems[Tool] then
		-- Destroy instances belonging to this buffer that haven't been popped
		for k in pairs (bufferItems[Tool]) do
			if k:GetAttribute("BufferPopped") == false then
				k:Destroy()
			end
		end
	end
end

function Export:Start()
	local itemContainer = Instance.new("Folder")
	itemContainer.Name = Configuration.BUFFER_FOLDER_NAME
	itemContainer.Parent = workspace
	
	local objectValue = script.Parent:FindFirstChild("_defaultBufferFolder") or Instance.new("ObjectValue")
	objectValue.Name = "_defaultBufferFolder"
	objectValue.Value = itemContainer
	objectValue.Parent = script.Parent
	
	local bufferOwnerChangedRemote = Instance.new("RemoteEvent")
	bufferOwnerChangedRemote.Name = "BufferOwnerChanged"
	bufferOwnerChangedRemote.Parent = script.Parent

	CollectionService:GetInstanceAddedSignal("BufferItem"):Connect(ItemAdded)
	CollectionService:GetInstanceRemovedSignal("BufferTool"):Connect(ToolRemoving)
end

return Export
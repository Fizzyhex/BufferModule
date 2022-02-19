local Types = require(script.Parent.Types)

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Configuration = require(script.Parent.Configuration)
local Janitor = require(script.Parent.Janitor)

local BUFFER_PLAYER_NAME = "_BufferPlayer"
local BUFFER_DISABLE_CAN_TOUCH = Configuration.BUFFER_DISABLE_CAN_TOUCH
local BUFFER_FOLDER_NAME = Configuration.BUFFER_FOLDER_NAME
local ENABLE_LOCAL_COLLISIONS = Configuration.ENABLE_LOCAL_COLLISIONS
local defaultBufferFolder: ObjectValue = script.Parent:WaitForChild("_defaultBufferFolder")
local bufferOwnerChanged: RemoteEvent = script.Parent:WaitForChild("BufferOwnerChanged")
local IS_CLIENT: boolean = RunService:IsClient()
local IS_SERVER = RunService:IsServer()
local randomGen: Random = Random.new()
local guardProperties = {
	["CanCollide"] = false,
	["CanQuery"] = false
}

if BUFFER_DISABLE_CAN_TOUCH then
	guardProperties["CanTouch"] = false
end

local function GetBufferFolder(instance: Instance)
	local folder: Instance | nil = instance:FindFirstChild(BUFFER_FOLDER_NAME)
	if folder then
		return folder
	else
		folder = Instance.new("Folder")
		folder.Name = BUFFER_FOLDER_NAME
		folder.Parent = instance
		
		return folder
	end
end

local function LiftGuards(instance: BasePart)
	if instance:IsA("BasePart") then
		for property, value in pairs (guardProperties) do
			if instance:GetAttribute("bfr_" .. property) then
				instance[property] = not value
				instance:SetAttribute("bfr_" .. property, nil)
			end
		end
	end
end

local function ApplyGuards(instance: BasePart)
	if instance:IsA("BasePart") then
		for property, value in pairs (guardProperties) do
			if ENABLE_LOCAL_COLLISIONS and instance:GetAttribute("LocalCollisions") then
				instance.CanCollide = false
			end
			
			if instance[property] ~= value then
				instance[property] = value
				instance:SetAttribute("bfr_" .. property, true)
			end
		end
	end
end

local function ApplyItemGuards(item)
	if item:IsA("BasePart") then
		ApplyGuards(item)
	end

	for _, v in pairs (item:GetDescendants()) do
		ApplyGuards(v)
	end
end

local function LiftItemGuards(item: Instance)
	if item:IsA("BasePart") then
		LiftGuards(item)
	end

	for _, v in pairs (item:GetDescendants()) do
		LiftGuards(v)
	end
	
	item:SetAttribute("_bufferOrder", nil)
end

local Export = {}
Export.__index = Export
export type Buffer = typeof(Buffer)

function Export:_refill(force: boolean?)
	if IS_SERVER then
		if self._autoRefill or (force == true) then
			local addItemFunction = self._addItemFunction

			if addItemFunction then
				local needed = (self._minItems :: number) - #self:GetUnsortedItems()
				if needed > 0 then
					for i = 1, needed do
						local newItem = addItemFunction(self)
						if newItem == nil then
							error("AddItemFunction returned no value!")
						else
							self:AddItem(newItem)
						end
					end
				end
			end
		end
	end
end

function Export:_onPlayerChanged(newPlayer: Player, oldPlayer)
	-- Migrate NetworkOwnership of buffer items to the new player.
	for _, item: Instance | Model | BasePart in pairs (self.itemContainer:GetChildren()) do
		if item:IsA("BasePart") then
			if item:CanSetNetworkOwnership() then
				item:SetNetworkOwner(newPlayer)
			end
		elseif item:IsA("Model") and item.PrimaryPart then
			if item.PrimaryPart:CanSetNetworkOwnership() then
				item.PrimaryPart:SetNetworkOwner(newPlayer)
			end
		end
		
		local bufferPlayerValue: ObjectValue = item:FindFirstChild(BUFFER_PLAYER_NAME)
		
		if bufferPlayerValue then
			bufferPlayerValue.Value = newPlayer
		end
	end
	
	if newPlayer then
		-- Let the new player's client know that they now own the buffer.
		bufferOwnerChanged:FireClient(newPlayer, self.itemContainer, self.INSTANCE, true)
	end
	
	if oldPlayer then
		-- Let the old player's client know that they no longer own the buffer.
		bufferOwnerChanged:FireClient(oldPlayer, self.itemContainer, nil, false)
	end
end

function Export:_updateOwnership(player: Player?)
	assert(IS_SERVER, "Internal error: _updateOwnership cannot be called from the client!")

	if self.itemContainer:IsDescendantOf(workspace) then
		local currentPlayer = player or self:GetCurrentPlayer()

		for _, item in pairs (self.itemContainer:GetChildren()) do
			if item:IsA("Model") then
				if item.PrimaryPart and item.PrimaryPart:CanSetNetworkOwnership() then
					item.PrimaryPart:SetNetworkOwner(currentPlayer)
				end
			elseif item:IsA("BasePart") and item:CanSetNetworkOwnership() then
				item:SetNetworkOwner(currentPlayer)	
			end

			pcall(function()
				item[BUFFER_PLAYER_NAME].Value = player
			end)
		end
	end
end

function Export:_init() -- Anything that needs to be done after setmetatable was called goes here
	if IS_SERVER then
		-- Update ownership of items when it's available
		local itemContainer = self.itemContainer
		local oldParent = itemContainer:IsDescendantOf(workspace)
		self._janitor:Add(itemContainer.AncestryChanged:Connect(function()
			if oldParent == false and itemContainer:IsDescendantOf(workspace) then
				oldParent = true
				self:_updateOwnership()
			end
		end))
	end

	return self :: Buffer
end

function Export.new(instance: Instance, bufferName: string): Buffer
	bufferName = bufferName or "UnnamedBuffer"
	
	local new = {}
	new.INSTANCE = instance
	new._janitor = Janitor.new()
	new._player = nil
	new._autoRefill = false
	new._minItems = 1
	new._lastOwner = nil
	
	if IS_SERVER then
		new._playerNeverSet = true
		new._bufferOrder = 0
		
		local itemContainer
		if instance:FindFirstChild(bufferName) then
			error("A buffer or other instance called '".. bufferName .. "' already exists under " .. instance:GetFullName() .. "!")
		else
			itemContainer = Instance.new("Folder")
			itemContainer.Name = bufferName
			itemContainer.Parent = instance
			new._janitor:Add(itemContainer)
		end
		
		new.itemContainer = itemContainer

	else
		new.itemContainer = (instance:WaitForChild(bufferName) :: Folder)
	end
	
	return setmetatable(new, Export):_init()
end

function Export:GetUnsortedItems()
	return self.itemContainer:GetChildren()
end

function Export:Refill()
	assert(IS_SERVER, "Buffer:Refill() cannot be called on the client")
	self:_refill(true)
end

function Export:SetAutoRefillEnabled(enabled: boolean)
	assert(IS_SERVER, "SetAutoRefillEnabled cannot be called from the client!")
	
	self._autoRefill = enabled
	self:_refill()
	return self :: Buffer
end

function Export:GetCurrentPlayer()
	assert(IS_SERVER, "GetPlayer cannot be called from the client!")
	return self._player
end

function Export:SetMinimumItems(minSize: number)
	assert(IS_SERVER, "SetMinimumItems cannot be called from the client!")
	
	self._minItems = minSize
	self:_refill()
	return self :: Buffer
end

function Export:SetCurrentPlayer(player)
	assert(IS_SERVER, "SetCurrentPlayer cannot be called from the client!")
	
	if self._player ~= player then
		self:_onPlayerChanged(player, self._player)
	end
	
	self._playerNeverSet = nil
	self._player = player
	self:_updateOwnership(player)
	return self :: Buffer
end

function Export:PopItem(silent: boolean?)
	assert((not self._playerNeverSet), "The Buffer has not yet had a player set. If you would like to call the buffer with no player, call Buffer:SetCurrentPlayer(nil) first.")
	
	local items = self:GetUnsortedItems()
	local item
	
	if IS_CLIENT and #items > 1 then
		local currentlyNext, currentlyNextOrder: number
		for _, item in pairs (items) do
			if currentlyNext == nil then
				currentlyNext = item
				currentlyNextOrder = item:GetAttribute("_bufferOrder") or 0
			else
				local itemOrder = item:GetAttribute("_bufferOrder") or 0
				if itemOrder < currentlyNextOrder then
					currentlyNext = item
					currentlyNextOrder = itemOrder
				end
			end
		end
		item = currentlyNext
	else
		item = items[1]
	end
	
	if item then
		LiftItemGuards(item)
		
		if IS_SERVER then
			item:SetAttribute("BufferPopped", true)
		else			
			item:SetAttribute("BufferPoppedClient", true)
			
			if not item:IsDescendantOf(workspace) then
				warn("PopItem returned nil because items can only be popped when the buffer is a descendant of the workspace")
				return nil
			end
		end
		
		local primaryPart: BasePart & {_PositionLock: BodyPosition}

		if item:IsA("BasePart") then
			primaryPart = item
		else
			pcall(function()
				primaryPart = item.PrimaryPart
			end)
		end

		if primaryPart then
			local positionLock = primaryPart:FindFirstChild("_PositionLock")
			
			if positionLock then
				positionLock:Destroy()
			end
			
			if IS_CLIENT then
				primaryPart.AssemblyLinearVelocity = Vector3.new()
				primaryPart.AssemblyAngularVelocity = Vector3.new()
			end
		end
		
		self:_refill()
		
		return item
	else
		if silent ~= true then
			warn("PopItem returned nil because the buffer is empty")
		end
		return nil
	end
end

function Export:SetItemConstructor(func: any)
	assert(IS_SERVER, "SetItemConstructor cannot be called from the client!")
	assert(typeof(func) == "function" or (typeof(func) == "table" and func.__call), "Argument #1 must be a function")
	
	self._addItemFunction = func
	self:_refill()
	
	return self :: Buffer
end

function Export:AddItem(item: Instance)
	assert(item ~= nil, "Argument #1 missing")
	assert(IS_SERVER, "AddItem cannot be called from the client!")

	local primaryPart
	if item:IsA("Model") then
		assert(item.PrimaryPart ~= nil, "Item is missing a PrimaryPart")
		primaryPart = item.PrimaryPart
	elseif item:IsA("BasePart") then
		primaryPart = item
	else
		error("Argument #1 must be a Model or BasePart")
	end
	
	assert((not primaryPart.Anchored), "Items added to the Buffer must be unanchored")
	
	local currentPlayer = self:GetCurrentPlayer()
	
	-- Pick a position to store the projectile in. This should be far away from the playable area.
	local lockPosition = Vector3.new(randomGen:NextInteger(-10^2, 10^2), 100000 - randomGen:NextInteger(0, 100), randomGen:NextInteger(-10^2, 10^2))
	item:PivotTo(CFrame.new(lockPosition))
	
	-- We have to 'anchor' the item with a BodyPosition, as traditionally anchoring it would prevent us from assigning network ownership.
	local PositionLock = Instance.new("BodyPosition")
	PositionLock.Name = "_PositionLock"
	PositionLock.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	PositionLock.Position = lockPosition
	PositionLock.Parent = primaryPart
	
	local bufferPlayer = Instance.new("ObjectValue")
	bufferPlayer.Name = BUFFER_PLAYER_NAME
	bufferPlayer.Value = currentPlayer
	bufferPlayer.Parent = item
	
	CollectionService:AddTag(item, "BufferItem")
	item:SetAttribute("BufferPopped", false)
	ApplyItemGuards(item)
	
	if #self:GetUnsortedItems() > 0 then
		self._bufferOrder += 1
	end
	item:SetAttribute("_bufferOrder", self._bufferOrder)
	
	-- Parent the item to the buffer.
	item.Parent = self.itemContainer
	
	-- Set ownership after the item is parented.
	if primaryPart:CanSetNetworkOwnership() then
		primaryPart:SetNetworkOwner(currentPlayer)
	end
	
	return self :: Buffer
end

function Export.Is(object)
	return typeof(object) == "table" and getmetatable(object) == Export
end

function Export:Destroy()
	self._janitor:Destroy()
end

return Export
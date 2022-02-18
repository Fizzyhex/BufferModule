local Types = require(script.Parent.Types)

local Buffer: Types.Buffer = {}
Buffer.__index = Buffer

local CollectionService = game:GetService("CollectionService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Configuration = require(script.Parent.Configuration)
local SignalDictonary = require(script.Parent.SignalDictonary)

local BUFFER_FOLDER_NAME = Configuration.BUFFER_FOLDER_NAME
local DEFAULT_LOCAL_COLLISIONS = Configuration.DEFAULT_LOCAL_COLLISIONS
local defaultBufferFolder: ObjectValue = script.Parent:WaitForChild("_defaultBufferFolder")
local isClient: boolean = RunService:IsClient()
local randomGen: Random = Random.new()

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

local function GetPrimary(Item)
	return (Item:IsA("BasePart") and Item) or (Item:IsA("Model") and Item.PrimaryPart) or Item:FindFirstChildWhichIsA("BasePart")
end

function Buffer:CleanItems()
	for i,v in pairs (self.Items) do
		if v.Instance and v.Instance.Parent == nil then
			self.Items[i] = nil
		end
	end
end

function Buffer:GetPlayer()
	if self.Attachment then
		local Player = self.Attachment:FindFirstAncestorOfClass("Player") or Players:GetPlayerFromCharacter(self.Attachment.Parent)
		if Player then
			return Player
		else
			return nil
		end
	end
end

function Buffer:GetItem()
	self:CleanItems()

	if Buffer.Items[1] then
		return self.Items[1].Instance
	end
end

function Buffer:PopItem()
	self:CleanItems()

	if self.Items[1] then
		local Item = self.Items[1]
		self.Items[1] = nil

		if Item.Primary:WaitForChild("PositionLock", 3) then
			Item.Primary.PositionLock:Destroy()
		end

		Item.Primary.Orientation = Vector3.new()
		Item.Primary.Velocity = Vector3.new()
		Item.Primary.RotVelocity = Vector3.new()
		
		CollectionService:RemoveTag(Item.Instance, "BufferItem")
		
		self._popBind:Fire(Item)
		
		return Item.Instance
	else
		warn("Attempt to pop an item in an empty buffer")
	end
end

function Buffer:AddItem(Item: Tool | Model | Instance, config: Types.BufferItemConfig) -- Call from the server
	assert(self.Attachment, "The buffer isn't attached to any instance")
	assert(isClient == false, "Buffer:AddItem() can only be called from the server")
	assert(not (config ~= nil and typeof(config) ~= "table"), "Argument #2: Expected table or nil, got " .. typeof(config))
	
	local localCollisions: boolean = DEFAULT_LOCAL_COLLISIONS or config.LocalCollisions
	config = config or {}
	
	local BufferOwner = Instance.new("ObjectValue")
	BufferOwner.Name = "BufferOwner"
	BufferOwner.Value = self.Attachment
	BufferOwner.Parent = Item
	
	-- Pick a position to store the projectile in. This should be far away from the playable area.
	local Position = Vector3.new(randomGen:NextInteger(-10^6, 10^6), 100000 - randomGen:NextInteger(0, 100), randomGen:NextInteger(-10^6, 10^6))

	if Item:IsA("Model") then
		Item:PivotTo(CFrame.new(Position))
	else
		Item:PivotTo(CFrame.new(Position))
	end	

	-- Hold the item in the air
	-- We have to 'anchor' the item with a BodyPosition, as traditionally anchoring it would prevent us from assigning network ownership.
	local PositionLock = Instance.new("BodyPosition")
	PositionLock.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	PositionLock.Position = Position
	PositionLock.Name = "PositionLock"
	PositionLock.Parent = GetPrimary(Item)

	CollectionService:AddTag(Item, "BufferItem")
	
	if localCollisions then
		Item:SetAttribute("_bfrNoColl", true)
	end
	
	-- Parent the Item before attempting to set its network owner
	Item.Parent = (workspace.StreamingEnabled and GetBufferFolder(self.Attachment)) or defaultBufferFolder.Value

	local Player: Player = self:GetPlayer()

	-- Set network ownership so that the client can control its physics
	for i,v in pairs (Item:GetDescendants()) do
		if v:IsA("BasePart") then
			if v:CanSetNetworkOwnership() then
				v:SetNetworkOwner(Player)
			end
			
			-- Disable collisions on the server side.
			if localCollisions and v.CanCollide then
				CollectionService:AddTag(v, "BufferOverwroteCollisions")
				v.CanCollide = false
			end
		end
	end

	if Item:IsA("BasePart") then
		if Item:CanSetNetworkOwnership() then
			Item:SetNetworkOwner(Player)
		end
		
		-- Disable collisions on the server side.
		if localCollisions and Item.CanCollide then
			CollectionService:AddTag(Item, "BufferOverwroteCollisions")
			Item.CanCollide = false
		end
	end
	
	return Item
end

function Buffer:Destroy() -- Call if you no longer need the buffer
	self.Items = {}
	self.Signals:Destroy()
end

function Buffer.new(instance: Instance)
	assert(instance ~= nil, "Argument #1 missing: Provide an Instance to attach the buffer to")
	local self: Types.Buffer = {Signals = SignalDictonary.new(), Items = {}, AttachmentInit = false, LastPlayer = nil}
	
	local PopBind = Instance.new("BindableEvent")
	self._popBind = PopBind
	self.Popped = PopBind.Event
	
	local LastPlayer

	self = setmetatable(self, Buffer)
	
	self.Attachment = instance
	self.Signals = SignalDictonary.Value.new()

	self.Signals:Add(instance:GetPropertyChangedSignal("Parent"):Connect(function()
		if self.Items[1] and self.Items[1].Instance then
			local Player = self:GetPlayer()

			if self.LastPlayer ~= Player then
				local Item = self.Items[1].Instance

				-- Set network ownership so that the client can control its physics
				for i,v in pairs (Item:GetDescendants()) do
					if v:IsA("BasePart") and v:CanSetNetworkOwnership() then
						v:SetNetworkOwner(Player)
					end
				end

				if Item:IsA("BasePart") and Item:CanSetNetworkOwnership() then
					Item:SetNetworkOwner(Player)
				end

				self.LastPlayer = Player
			end
		end
	end))
	
	return self
end

return Buffer
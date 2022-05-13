local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Configuration = require(script.Parent.Configuration)
local Buffer = require(script.Parent.Buffer)

local LOCAL_PLAYER = Players.LocalPlayer
local ENABLE_LOCAL_COLLISIONS = Configuration.ENABLE_LOCAL_COLLISIONS
local HIDE_UNPOPPED_ITEMS = Configuration.HIDE_UNPOPPED_ITEMS
local PROJECTILE_TAG = "BufferItem"
local REFERENCE_TAG = "BufferReference"
local TOOL_TAG = "BufferTool"
local bufferStorage

local function Timeout(maxTime: number, condition)
	local start = tick()
	local result
	while tick() - start < maxTime do
		result = {condition()}
		
		if result[1] then
			break
		end
		
		task.wait()
	end
	return unpack(result)
end

local function OnProjectileAdded(projectile: Model | BasePart | Instance)
	local bufferPlayerValue: ObjectValue? = projectile:WaitForChild("_BufferPlayer", 5)

	if bufferPlayerValue then
		local bufferPlayer: ObjectValue? = Timeout(5, function()
			return bufferPlayerValue.Value
		end)

		if bufferPlayer then
			if bufferPlayer == LOCAL_PLAYER then
				if ENABLE_LOCAL_COLLISIONS then
					-- Re-enable collisions
					for _, part: Instance | BasePart in pairs (projectile:GetDescendants()) do
						if part:IsA("BasePart") and (part:GetAttribute("LocalCollisions") or CollectionService:HasTag(part, "LocalCollisions")) then
							part.CanCollide = true
						end
					end

					if projectile:IsA("BasePart") and (projectile:GetAttribute("LocalCollisions") or CollectionService:HasTag(projectile, "LocalCollisions")) then
						projectile.CanCollide = true
					end
				end
			else
				if HIDE_UNPOPPED_ITEMS then
					projectile.Parent = bufferStorage
				end
			end
		end
	end
end

--local function OnProjectileRemoved(projectile: Model | BasePart | Instance)
--end

local Export = {}

function Export:Start()
	local BufferOwnerChanged: RemoteEvent = script.Parent:WaitForChild("BufferOwnerChanged")
	
	bufferStorage = Instance.new("Folder")
	bufferStorage.Name = "_BufferStorage"
	bufferStorage.Parent = ReplicatedStorage
	
	CollectionService:GetInstanceAddedSignal(PROJECTILE_TAG):Connect(OnProjectileAdded)
	--CollectionService:GetInstanceRemovedSignal(PROJECTILE_TAG):Connect(OnProjectileRemoved)
	
	BufferOwnerChanged.OnClientEvent:Connect(function(buffer: Instance, newParent: Instance?, owned: boolean)
		if HIDE_UNPOPPED_ITEMS then
			if owned then
				buffer.Parent = newParent
				
				for _, bufferItem in ipairs (buffer:GetChildren()) do
					if CollectionService:HasTag(bufferItem, PROJECTILE_TAG) then
						task.spawn(function()
							OnProjectileAdded(bufferItem)
						end)
					end
				end
			else
				buffer.Parent = bufferStorage
			end
		end
	end)
	
	for i, projectile in pairs (CollectionService:GetTagged(PROJECTILE_TAG)) do
		task.spawn(function()
			OnProjectileAdded(projectile)
		end)
	end
end

return Export
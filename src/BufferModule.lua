-- Fizzyhex (Roblox @Fizzyhex), 2022
-- github/Fizzyhex/BufferModule

local RunService = game:GetService("RunService")

local Configuration = require(script:WaitForChild("Configuration"))

local IS_CLIENT = RunService:IsClient()

local Export = {}
Export.initalized = false
Export.Util = {}
Export.new = nil

function Export:Init()
	assert(self.initalized == false, "BufferModule is already initalized on the " .. ((IS_CLIENT and "client!") or "server!"))
	self.initalized = true
	
	local Module
	if IS_CLIENT then
		Module = require(script:WaitForChild("BufferClient"))
	else
		Module = require(script:WaitForChild("BufferServer"))
	end
	
	Module:Start()
	
	local Buffer = require(script.Buffer)
	self.new = Buffer.new
	self.Buffer = Buffer

	return self
end

function Export:CreateBuffer(instance: Instance, bufferName: string): typeof(require(script.Buffer))
	return self.new(instance, bufferName)
end

function Export.Util.RegisterTouchInterest(part: BasePart)
	local transmitter = part:FindFirstChildWhichIsA("TouchTransmitter")
	
	if not transmitter then
		part.CanTouch = true
		
		local touchConnection = part.Touched:Connect(function() end)
		local childConnection, parentConnection: RBXScriptConnection
		
		local function Clean()
			touchConnection:Disconnect()
			childConnection:Disconnect()
			parentConnection:Disconnect()
		end
		
		childConnection = part.ChildAdded:Connect(function(child)
			if child:IsA("TouchTransmitter") then
				-- Destroy our transmitter if there's another one.
				-- This is to prevent touches from registering twice.
				Clean()
			end
		end)
		
		parentConnection = part:GetPropertyChangedSignal("Parent"):Connect(function()
			if part.Parent == nil then
				task.wait()
				if not parentConnection.Connected then
					-- Our connection was disconnected by Instance:Destroy()
					Clean()
				end
			end
		end)
	end
end

Export:Init()

return Export
